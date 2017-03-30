module HumanComputer
  # Base class shared by HumanProcessor and SimulatedProcessor
  class Processor
    class << self
      # Convert integer to padded 8bit binary string
      def eight_bitify(integer)
        integer.to_s(2).rjust(8, '0')
      end
    end

    attr_accessor(
      # Represented in the UI as a large grid, pannable and zoomable like a google map
      :memory,
      # Pointer to the current instruction
      :program_counter,
      # Current instruction values, with the result address appended
      :current_instruction
    )

    # Pass in a memory class, likely either DB persisted or a simple in-memory hash
    def initialize(memory_class = HashMemory)
      @debugger = Debugger.new self
      @memory_class = memory_class
      @program_counter = self.class.eight_bitify 1
      @cycle = 0
    end

    # Given an assembler DSL file, assemble it and load into memory
    def boot(program)
      path = "programs/#{program}.rb"
      assembler = Assembler.new
      assembler.assemble path
      pid = Pid.create name: program, memory_class: @memory_class
      @memory = pid.memory
      @memory.flash assembler.data
      @program_counter = assembler.program_start
    end

    # Load an already running program into memory
    def resume(pid)
      pid = Pid.find(pid)
      @memory = pid.memory
    end

    # Fetch the values for this iteration from memory
    def retrieve_arg_locations
      int_pc = @program_counter.to_i(2)
      subtrahend = @program_counter
      minuend = self.class.eight_bitify(int_pc + 1)
      goto = self.class.eight_bitify(int_pc + 2)
      [subtrahend, minuend, goto]
    end
  end
end
