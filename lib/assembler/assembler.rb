# Assembles DSL assembly files into bytecode
class Assembler
  attr_accessor :data
  BITS = 8

  def assemble(path = nil, &block)
    @path = path
    @code = block if block_given?
    fail Exception, 'Nothing to assemble' unless @path || @code
    evaluate_dsl
    @data.unshift 0 # The first byte is reserved and set to 0
    cast_pass
    wrap_label_around_next_item
    make_memory_addressable
    replace_symbols_with_refs
    convert_next_classes_to_refs
  end

  # Evaluate the commands in the file to build up an array of bytes.
  def evaluate_dsl
    # `Macros` contains all the basic instructions for our 'CPU'.
    # It also defines the DSL commands using the Cleanroom gem.
    assembler = Macros.new
    assembler.data = []
    if @path
      assembler.evaluate_file @path
    else
      assembler.evaluate(&@code)
    end
    @data = assembler.data
  end

  # Cast non-binary data to binary
  def cast_pass
    casted = []
    @data.length.times do |index|
      if @data[index].is_a? Hash
        # `remaining` contains data greater than the single byte used for the memory marker
        hash, remaining = cast_inside_hash(@data[index])
        casted.concat [hash, *remaining]
      else
        casted.concat cast(@data[index])
      end
    end
    @data = casted
  end

  # Cast the object inside the hash. Remembering that hashes are only used to label positions in
  # memory.
  def cast_inside_hash(hash)
    # Unpack the hash
    key = hash.keys.first
    value = hash.values.first
    # Repack the hash.
    # The label for the hash need only point to the first item. Either the program should know
    # how long the data is or do something like use zero-terminated srings.
    # So [{:a => [1,2,3]}] becomes [{:a => '1'}, ['10', '11']]
    casted_values = cast(value)
    first_item = casted_values.shift
    remaining = casted_values
    [{ key => first_item }, remaining]
  end

  # Cast a ruby object into a binary string.
  # Always returns array.
  def cast(object)
    case object
    when Integer
      [HumanComputer.eight_bitify(object)]
    when String
      cast_string object
    else
      [object]
    end
  end

  # Cast a string into ASCII binary representation
  def cast_string(string)
    # Convert characters to their ASCII integer representations
    ascii_representations = string.split('').map(&:ord)
    # Convert ASCII integres to bytes
    string_of_bytes = ascii_representations.map { |i| HumanComputer.eight_bitify i }
    # All strings should be zero-terminated
    string_of_bytes << HumanComputer.eight_bitify(0)
  end

  # Given a sequential list of bytes, give each byte an 8 bit memory address
  def make_memory_addressable
    hash = {}
    @data.length.times do |index|
      key = HumanComputer.eight_bitify index
      hash[key] = @data[index]
    end
    @data = hash
  end

  # Look for hashes with Macro::Labels and use them to mark the next item
  def wrap_label_around_next_item
    @data.length.times do |index|
      next unless a_label? @data[index]
      symbol = @data[index].values.first
      # Place the label in the next @data item, so it's picked up by replace_symbols_with_refs()
      @data[index + 1] = { symbol => @data[index + 1] }
      # Delete it from the array as it's job is done
      @data.delete_at index
    end
  end

  # Is the item a label placeholder?
  def a_label?(item)
    item.is_a?(Hash) && item.keys.first == Macros::Label
  end

  # The `mem` and `lbl` commands in the DSL provide the convenience of using :symbols as
  # placeholders for memory addresses.
  def replace_symbols_with_refs
    symbol_defs = symbols_first_pass
    symbols_second_pass symbol_defs
  end

  # Find the symbol definition hashes, make a note of their locations and replace the
  # definition with the value.
  def symbols_first_pass
    symbol_defs = {}
    @data.each do |address, byte|
      next unless byte.is_a? Hash
      symbol = byte.keys.first
      value = byte.values.first
      # Store the symbol and its address for the second pass
      symbol_defs[symbol] = address
      # Replace the definition with just the value
      @data[address] = value
    end
    symbol_defs
  end

  # If a symbol is being used as a memory pointer then assemble the address using a negative
  # number to represent indirect memory access. Then during runtime the value will be fetched
  # like so: memory[memory[|address|]]. Therefore using the modulus, fetching the value from
  # memory (which is itself a normal memory address) and then fetching that subsequent address
  # from memory.
  def convert_binary_to_signed_negative(address)
    twos_compliment = convert_to_signed_twos_complement address.to_i(2)
    HumanComputer.eight_bitify twos_compliment
  end

  # We use the 2s compliment convention of representing negative numbers through the first bit.
  def convert_to_signed_twos_complement(integer)
    upper = 2**BITS
    upper - integer
  end

  # Replace symbols with the memory addresses they represent
  def symbols_second_pass(symbol_defs)
    @data.each do |i, byte|
      next unless byte.is_a?(Symbol) || byte.is_a?(Pointer)
      symbol = byte.is_a?(Pointer) ? byte.symbol : byte
      address = symbol_defs[symbol]
      # Check if address needs to be assembled as an indirect memory reference
      address = convert_binary_to_signed_negative(address) if byte.is_a? Pointer
      @data[i] = address
    end
  end

  # The NextInstruction class constant is used as a placeholder to override the 'branch when
  # negative' part of SUBLEQ. Instead of branching force continuation to the next instruction.
  def convert_next_classes_to_refs
    @data.each do |address, byte|
      next unless byte == Macros::NextInstruction
      next_instruction_int = address.to_i(2) + 1
      next_instruction_bin = HumanComputer.eight_bitify(next_instruction_int)
      @data[address] = next_instruction_bin
    end
  end
end
