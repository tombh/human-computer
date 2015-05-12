module HumanComputer
  # Memory
  class PersistedMemory
    def initialize(process)
      @memory = Memory.find_by(process: process)
      @grid = @memory.grid
    end

    # Flash the *entire* memory. Done by the assembler.
    def flash(data)
      @memory.grid = data
      @memory.save!
    end

    def read(location)
      @data[location]
    end

    def write(location, tiles)
      @data[location] = tiles
      @memory.grid = @data
      @memory.save!
    end

    def size
      @data.length
    end
  end
end
