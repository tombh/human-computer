module HumanComputer
  # Simulate the activities a human would make. Used for *testing* only.
  # The Human Processor is completely carried out by humans, so we need this to test that our computer
  # and assembler work.
  class SimulatedProcessor < Processor
    ZERO  = '00000000'
    ONE   = '00000001'
    THREE = '00000011'

    def run
      fail 'No program loaded' unless @memory.size > 1
      begin
        subleq while @program_counter != '00000000'
      rescue StandardError
        # Just append the current instruction arguments, in case they're helpful
        appended_message =  $ERROR_INFO.message
        appended_message += "\npc: #{retrieve_arg_locations}"
        appended_message += "\ncurrent instruction: #{@current_instruction}"
        raise $ERROR_INFO, appended_message, $ERROR_INFO.backtrace
      end
    end

    # The SUBLEQ instruction as a basis for an OISC.
    # This is the Flux Capacitor of the entire project!
    # For more info, see:
    # https://esolangs.org/wiki/Subleq
    # http://techtinkering.com/2009/03/29/hello-world-in-subleq-assembly/
    def subleq
      @debugger.snapshot

      @cycle += 1

      # STEP 1
      # Retrieve instructions
      # May include resolving an indirect memory address
      arg1, arg2, goto_location, result_location = retrieve_instruction

      # STEPS 2 and 3
      # Subtract
      # Includes flipping the bits and a full adder across all the bits
      result, _carry = subtract arg2, arg1

      # STEP 4
      # Assign result to memory
      # May include resolving an indirect memory address
      memory_set result_location, result

      # STEP 5
      # Where in memory is the next instruction?
      # Either the result of a positive SUBLEQ or just return the incremented program counter
      set_next_instruction result, goto_location
    end

    def memory_fetch(location)
      @memory.read resolve_pointer(location)
    end

    def memory_set(location, value)
      @memory.write resolve_pointer(location), value
    end

    # Addresses starting with '1' are memory pointers, so take a further step and fetch the byte
    # that the pointer points to.
    def resolve_pointer(address)
      return address unless address[0] == '1'
      memory_fetch calculate_twos_compliment(address)
    end

    # Retrieve the current instruction being pointed to by @program_counter
    # NB. SUBLEQ arguments are all pointers to locations in memory.
    def retrieve_instruction
      # Get the pointers
      locations = retrieve_arg_locations
      arg1_location = memory_fetch locations[0]
      arg2_location = memory_fetch locations[1]

      # Resolve the fisrt 2 bytes to their actual values, because they are arguments, not pointers
      arg1_value = memory_fetch arg1_location
      arg2_value = memory_fetch arg2_location

      goto = memory_fetch locations[2]

      # Make a note of the current arguments and addresses for debugging
      @current_instruction = [arg1_value, arg2_value, goto, arg2_location]
    end

    def set_next_instruction(result, goto_location)
      # We're using signed bytes so negative numbers will have a 1 in position 0.
      unless result[0] == '1' || result == ZERO
        goto_location, _carry = add @program_counter, THREE
      end
      @program_counter = goto_location
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

    # A 'full adder' is the technical name for a boolean adder.
    # See http://en.wikipedia.org/wiki/Adder_(electronics)#Full_adder
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
end
