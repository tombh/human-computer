require 'cleanroom'

# Collection of macros that form an assembler
class Macros
  include Cleanroom

  # Used to replace a blank goto-override
  class NextInstruction; end

  # First memory location, should always be reset to 0
  Z = 0

  # The program data as an array of bytes
  attr_accessor :data

  # Jump straight to a new instruction
  # Resets mem[0] to 0
  def jmp(location)
    @data.concat [Z, Z, location]
  end
  expose :jmp

  # Subtract mem[a] from mem[b]
  def sub(a, b)
    @data.concat [a, b, NextInstruction]
  end
  expose :sub

  # Add mem[a] to mem[b], assumes mem[Z] = 0
  def add(a, b)
    # As mem[Z] contains 0, stores negative of mem[a] at mem[Z]
    sub a, Z
    # Equivalent to: mem[b] = mem[b] - -mem[a], ie mem[b] = mem[b] + mem[a]
    sub Z, b
    # Reset mem[Z] to zero
    sub Z, Z
  end
  expose :add

  # Copy mem[a] to mem[b], assumes mem[Z] = 0
  def mov(a, b)
    # Set mem[b] to zero
    sub b, b
    # Add mem[a] to mem[b]
    add a, b
  end
  expose :mov

  # Mark the end of program execution. Memeory after thie can be used for data
  def fin
    @data.concat [Z, Z, Z]
  end
  expose :fin

  # Write directly to memory.
  # `symbol` is a label that is converted into a memory address
  # The assembler iterates through the bytes looking for hashes with symbol in them.
  def mem(symbol, value)
    @data << { symbol => value }
  end
  expose :mem
end
