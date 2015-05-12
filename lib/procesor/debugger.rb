module HumanComputer
  # Output the state of the computer for debugging/visualisation purposes.
  # Used only for the simulayed processor.
  class Debugger
    # The width, in bytes, of the outputted memory grid
    WIDTH = 6

    def initialize(processor)
      @processor = processor
    end

    # Output a snapshot of the memory
    def snapshot
      return unless ENV['DEBUG']
      puts "Cycle #{@cycle}. Green shows the current instruction. Red is a modulus memory pointer."
      @cols = 0
      @reserved_addresses_done = false
      @processor.memory.clone.each do |address, byte|
        output address, byte
        carriage_return
        new_line_after_reserved_addresses
      end
      puts "\n\n"
    end

    private

    def output(address, byte)
      # Show indirect memory addresses as their resolved address and in red
      # TODO: Only do this to known subleq instructions, not memory as well
      byte = red "#{@processor.calculate_twos_compliment(byte)}" if byte[0] == '1'

      # Show the currently executing address as green
      address = green(address) if address == @processor.program_counter

      print "#{address}|#{byte} "
    end

    # Put a new line after the reserved addresses, so they appear apart from the main memory
    def new_line_after_reserved_addresses
      return if @reserved_addresses_done
      print "\n"
      @reserved_addresses_done = true
      @cols = 0
    end

    # Show the memory grid as WIDTH cols long
    def carriage_return
      @cols += 1
      return unless @cols == WIDTH
      puts "\n"
      @cols = 0
    end

    def colorize(text, color_code)
      "\e[#{color_code}m#{text}\e[0m"
    end

    def red(text)
      colorize(text, 31)
    end

    def green(text)
      colorize(text, 32)
    end
  end
end
