module HumanComputer
  # Memory
  class PersistedMemory
    def initialize(process = nil)
      @process = process || Process.create
    end

    # Flash the *entire* memory. Done by the assembler.
    def flash(data)
      data.each do |address, byte|
        tiles = []
        byte.each_char do |bit|
          tile = bit == '0' ? zero_tile : one_tile
          tiles << tile
        end
        write address, tiles
      end
    end

    def read(address)
      Memory.find_by process: @process, address: address
    end

    def write(address, tiles)
      memory = Memory.find_or_create_by(
        process: @process,
        address: address
      )

      memory.tiles = tiles
      memory.save!
    end

    def size
      Memory.where(process: @process).count
    end

    private

    ##
    # Pre-existing human-drawn versions to bootstrap the program
    ##

    def create_tile(paths)
      Tile.new paths: paths
    end

    def zero_tile
      create_tile File.read 'spec/fixtures/zero.json'
    end

    def one_tile
      create_tile File.read 'spec/fixtures/one.json'
    end
  end
end
