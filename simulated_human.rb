# Simulate the activities a human would make. Used for *testing* only
class SimulatedHuman
  ZERO  = '00000000'
  ONE   = '00000001'
  THREE = '00000011'

  attr_accessor :memory, :program_counter

  def initialize(memory, program_counter)
    @memory = memory
    @program_counter = program_counter
  end

  # The SUBLEQ instruction as a bases for an OISC
  def subleq
    # --------
    # STEPS 1, 2 and 3
    # Subtract
    # --------
    subtrahend_location, minuend_location, goto_location = retrieve_arg_locations
    result, _carry = subtract @memory[minuend_location], @memory[subtrahend_location]

    # -----------------------
    # STEP 4
    # Assign result to memory
    # -----------------------
    @memory[minuend_location] = result

    # ----------------------------------------
    # STEP 5
    # Where in memory is the next instruction?
    # ----------------------------------------
    # We're using signed bytes so negative numbers will have a 1 in position 0.
    if result[0] == '1' || result == ZERO
      @program_counter = @memory[goto_location]
    else
      @program_counter, _carry = add @program_counter, THREE
    end
  end

  # Fetch the values for this iteration from memory
  def retrieve_arg_locations
    # No need to use human addition here, I think it's reasonable for the computer to assist in
    # fetching the 3 adjacent bytes.
    int_pc = @program_counter.to_i(10)
    subtrahend = @program_counter
    minuend = eight_bitify(int_pc + 1)
    goto = eight_bitify(int_pc + 2)
    [subtrahend, minuend, goto]
  end

  # Binary subtraction of signed bytes using 2's compliment method.
  # Minuend is the number having something subtracted.
  # Subtrahend is the number being taken away from the other number.
  # Therefore: difference = minuend - subtrahend
  def subtract(minuend, subtrahend)
    # 2's compliment method
    # STEP 1: flip bits
    flipped = flip subtrahend
    # STEP 2: increment
    twos_compliment, _carry = add flipped, ONE

    # STEP 3
    # Adding the 2's compliment to the minuend is the same as subtracting
    add minuend, twos_compliment
  end

  # Flip a bit to its opposite sign
  # UI example:
  # [0] [1] [0] [1] [1] [1] [0] [1]
  # [ ] [ ] [ ] [ ] [ ] [ ] [ ] [ ]
  # "Flip each bit!"
  # [1] [0] [1] [0] [0] [0] [1] [0]
  def flip(subtrahend)
    subtrahend.split('').map { |i| i == '0' ? '1' : '0' }.join
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

  # Convert integer to padded 8bit binary string
  def eight_bitify(integer)
    integer.to_s(2).rjust(8, '0')
  end
end
