module HumanComputer
  # A simple memory interface that just uses a ruby hash
  class HashMemory
    # `process` is not needed, it's present here to be compatible with PersistedMemory
    def initialize(_process = nil)
      @data = {}
    end

    # Flash the *entire* memory. Done by the assembler.
    def flash(data)
      @data = data
    end

    def read(location)
      @data[location]
    end

    def write(location, value)
      @data[location] = value
    end

    def size
      @data.length
    end
  end
end
