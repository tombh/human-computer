# Simulate the activities a human would make. Used for *testing* only
class SimulatedHuman
  ZERO  = '00000000'
  ONE   = '00000001'
  THREE = '00000011'

  attr_accessor :memory, :program_counter, :cycle

  def initialize(computer)
    @computer = computer
    @cycle = 0
  end

  def memory_fetch(location)
    location = resolve_pointer(location) if location[0] == '1'
    @computer.memory[location]
  end

  def memory_set(location, value)
    location = resolve_pointer(location) if location[0] == '1'
    @computer.memory[location] = value
  end

  # Addresses starting with '1' are memory pointers, so take a further step and fetch the byte
  # that the pointer points to.
  def resolve_pointer(address)
    memory_fetch calculate_twos_compliment address
  end

  def colorize(text, color_code)
    "\e[#{color_code}m#{text}\e[0m"
  end

  def red(text); colorize(text, 31); end
  def green(text); colorize(text, 32); end

  def debug
    dump = @computer.memory.clone
    puts "Cycle #{@cycle}. Green shows the current instruction. Red is a modulus memory pointer."
    cols = 0
    reserved_addresses_done = false
    dump.each do |address, byte|
      if byte[0] == '1'
        # TODO: Only do this to known subleq instructions, not memory as well
        byte = red "#{calculate_twos_compliment(byte)}"
      end
      address = green(address) if address == @computer.program_counter
      print "#{address}|#{byte} "
      unless reserved_addresses_done
        print "\n"
        reserved_addresses_done = true
        next
      end
      cols += 1
      if cols == 6
        puts "\n"
        cols = 0
      end
    end
    puts "\n\n"
  end

  # The SUBLEQ instruction as a basis for an OISC
  def subleq
    debug if ENV['DEBUG']

    @cycle += 1

    arg1, arg2, goto_location, result_location = retrieve_instruction

    # --------
    # STEPS 1, 2 and 3
    # Subtract
    # --------
    result, _carry = subtract arg2, arg1

    # -----------------------
    # STEP 4
    # Assign result to memory
    # -----------------------
    memory_set result_location, result

    # ----------------------------------------
    # STEP 5
    # Where in memory is the next instruction?
    # ----------------------------------------
    set_next_instruction result, goto_location
  end

  # Retrieve the current instruction being pointed to by @computer.program_counter
  # NB. subleq arguements are all pointers to locations in memory.
  def retrieve_instruction
    # Get the pointers
    locations = @computer.retrieve_arg_locations
    # Resolve the fisrt 2 pointers to their actual values
    arg1_location = memory_fetch locations[0]
    arg2_location = memory_fetch locations[1]
    arg1_value = memory_fetch arg1_location
    arg2_value = memory_fetch arg2_location
    goto = memory_fetch locations[2]
    @computer.current_instruction = [arg1_value, arg2_value, goto, arg2_location]
  end

  def set_next_instruction(result, goto_location)
    # We're using signed bytes so negative numbers will have a 1 in position 0.
    unless result[0] == '1' || result == ZERO
      goto_location, _carry = add @computer.program_counter, THREE
    end
    @computer.program_counter = goto_location
  end

  # Binary subtraction of signed bytes using 2's compliment method.
  # Minuend is the number having something subtracted.
  # Subtrahend is the number being taken away from the other number.
  # Therefore: difference = minuend - subtrahend
  def subtract(minuend, subtrahend)
    twos_compliment = calculate_twos_compliment subtrahend

    # Adding the 2's compliment to the minuend is the same as subtracting
    add minuend, twos_compliment
  end

  def calculate_twos_compliment(byte)
    flipped = flip byte
    result, _carry = add flipped, ONE
    result
  end

  # Flip a bit to its opposite sign
  # UI example:
  # [0] [1] [0] [1] [1] [1] [0] [1]
  # [ ] [ ] [ ] [ ] [ ] [ ] [ ] [ ]
  # "Flip each bit!"
  # [1] [0] [1] [0] [0] [0] [1] [0]
  def flip(byte)
    byte.split('').map { |i| i == '0' ? '1' : '0' }.join
  end

  # Add two binary values
  # Given the 2 values 1001 and 1101 the UI example would be:
  #                  [      result      ]
  # [arg1] [arg2]    [ [sum1]     [Cin] ]   [Cout]
  # ----------------------------------------------
  # [ 1  ] [ 1  ] -> [ [XOR ] XOR [0  ] ] , [AND ]
  # ----------------------------------------------
  # [ 0  ] [ 1  ] -> [ [XOR ] XOR [*  ] ] , [AND ]
  # ----------------------------------------------
  # [ 0  ] [ 0  ] -> [ [XOR ] XOR [*  ] ] , [AND ]
  # ----------------------------------------------
  # [ 1  ] [ 1  ] -> [ [XOR ] XOR [*  ] ] , [AND ]
  # ----------------------------------------------
  def add(augend, addend)
    result = []
    carry = '0'
    8.times do |i|
      position = 7 - i # Go from the end of the byte to the beginning
      augend_bit = augend[position]
      addend_bit = addend[position]

      sum, carry = full_adder augend_bit, addend_bit, carry
      result[position] = sum
    end
    [result.join, carry]
  end

  # A 'full adder' is the technical name for a boolean adder
  def full_adder(augend, addend, carry_in)
    intermediate_sum = boolean_xor augend, addend
    sum = boolean_xor intermediate_sum, carry_in

    carry1 = boolean_and augend, addend
    carry2 = boolean_and intermediate_sum, carry_in
    carry_out = boolean_xor carry1, carry2

    [sum, carry_out]
  end

  # Are the two bits both '1'?
  def boolean_and(left, right)
    both_one = left == '1' && right == '1'
    both_one ? '1' : '0'
  end

  # Are the two bits different?
  def boolean_xor(left, right)
    left != right ? '1' : '0'
  end
end
