# Assembles DSL assembly files into bytecode
class Assembler
  attr_accessor :data

  def assemble(path = nil, &block)
    @path = path
    @code = block if block_given?
    fail Exception, 'Nothing to assemble' unless @path || @code
    evaluate_dsl
    make_memory_addressable
    replace_symbols_with_refs
    convert_next_classes_to_refs
    cast_data_to_binary
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
  def cast_data_to_binary
    @data.each do |address, byte|
      @data[address] = Computer.eight_bitify byte if byte.is_a? Integer
    end
  end

  # Given a sequential list of bytes, give each byte an 8 bit memory address
  def make_memory_addressable
    # The first byte is reserved and set to 0
    @data.unshift 0

    hash = {}
    index = 0
    @data.each do |byte|
      key = Computer.eight_bitify index
      hash[key] = byte
      index += 1
    end
    @data = hash
  end

  # The `mem` command in the DSL provides the convenience of using :symbols as placeholders for
  # memory addresses
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
      # Replace the defintion with just the value
      @data[address] = value
    end
    symbol_defs
  end

  # Replace symbols with their memory addresses
  def symbols_second_pass(symbol_defs)
    @data.each do |address, byte|
      next unless byte.is_a? Symbol
      @data[address] = symbol_defs[byte]
    end
  end

  # The NextInstruction class constant is used as a placeholder to override the 'branch when
  # negative' part of SUBLEQ. Instead of branching force continuation to the next instruction.
  def convert_next_classes_to_refs
    @data.each do |address, byte|
      next unless byte == Macros::NextInstruction
      next_instruction_int = address.to_i(2) + 1
      next_instruction_bin = Computer.eight_bitify(next_instruction_int)
      @data[address] = next_instruction_bin
    end
  end
end
