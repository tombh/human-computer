module HumanComputer
  # Cast non binary values in assembler program to binary
  class Caster
    class << self
      # Iterate over all the data
      def cast_pass(data)
        casted = []
        data.length.times do |index|
          if data[index].is_a? Hash
            # `remaining` contains data greater than the single byte used for the memory marker
            hash, remaining = cast_inside_hash(data[index])
            casted.concat [hash, *remaining]
          else
            casted.concat cast(data[index])
          end
        end
        casted
      end

      # Cast a ruby object into a binary string.
      # Always returns array.
      def cast(object)
        case object
        when Integer
          [HumanComputer::Processor.eight_bitify(object)]
        when String
          cast_string object
        else
          [object]
        end
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

      # Cast a string into ASCII binary representation
      def cast_string(string)
        # Convert characters to their ASCII integer representations
        ascii_representations = string.split('').map(&:ord)
        # Convert ASCII integres to bytes
        string_of_bytes = ascii_representations.map { |i| HumanComputer::Processor.eight_bitify i }
        # All strings should be zero-terminated
        string_of_bytes << HumanComputer::Processor.eight_bitify(0)
      end
    end
  end
end
