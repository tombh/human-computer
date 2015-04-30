# Proof of concept for human-based SUBLEQ computer.
# The fundamental principle to follow is: it should be possible to play as a board game.
class Computer
  attr_accessor(
    # This would be a large board with lots of cells or a pannable google maps-style map of cells
    :memory,
    # Pointer to the current instruction
    :program_counter,
    # Current instruction values, with the result address appended
    :current_instruction
  )

  def initialize
    # Where the first instruction is located
    @program_counter = '00000001'
  end

  # Given an assembler DSL file, assemble it and load into memory
  def load(program)
    path = "programs/#{program}.rb"
    assembler = Assembler.new
    assembler.assemble path
    @memory = assembler.data
  end

  def run
    fail 'No program loaded' unless @memory.length > 1
    # Stub out a simulated human to run the program
    @runner = SimulatedHuman.new self
    begin
      @runner.subleq while @program_counter != '00000000'
    rescue StandardError
      # Just append the current instruction arguments, in case they're helpful
      appended_message =  $ERROR_INFO.message
      appended_message += "\npc: #{retrieve_arg_locations}"
      appended_message += "\ncurrent instruction: #{@current_instruction}"
      raise $ERROR_INFO, appended_message, $ERROR_INFO.backtrace
    end
  end

  # Fetch the values for this iteration from memory
  def retrieve_arg_locations
    int_pc = @program_counter.to_i(2)
    subtrahend = @program_counter
    minuend = self.class.eight_bitify(int_pc + 1)
    goto = self.class.eight_bitify(int_pc + 2)
    [subtrahend, minuend, goto]
  end

  # Convert integer to padded 8bit binary string
  def self.eight_bitify(integer)
    integer.to_s(2).rjust(8, '0')
  end
end
