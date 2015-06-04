# Memory stored in a database
class PersistedMemory
  def initialize(pid)
    @pid = Pid.find pid
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
    Address.find_by process: @pid, address: address
  end

  def write(address, tiles)
    byte = Address.find_or_create_by(
      pid: @pid,
      address: address
    )
    byte.tiles = tiles
    byte.save!
  end

  def usage
    Address.where(pid: @pid).count
  end

  # In order to represent the memory to users, the adddresses are split up into a square grid. The
  # frontend rendering code needs to know the dimensions of the grid.
  # Eg; 4x5;
  # ---------------------------------------
  # | 00001111 10101010 00001111 10101010 |
  # | 00001111 10101010 00001111 10101010 |
  # | 00001111 10101010 00001111 10101010 |
  # | 00001111 10101010 00001111 10101010 |
  # | 00001111 10101010 00001111 10101010 |
  # ---------------------------------------
  def dimensions
    byte_size = @pid.byte_size
    # Calculate total possible bytes, accounting for signed bytes
    total_bytes = 2**(byte_size - 1)
    # If all the bytes are placed in a aquare grid, calculate the length of a side
    side_length = Math.sqrt total_bytes
    x = side_length.floor
    # If the grid cannot be exactly sqsuare then add an extra row
    y = side_length == x ? y : x + 1
    # The width of the grid will be byte-size-times wider than the height
    x *= byte_size
    { x: x, y: y }
  end

  # We use a traditional geomapping concept called quadtrees to calculate which tiles to render for a
  # given section of the grid at a given zoom level. At the highest zoom level a quadtree tile will
  # exactly represent a single memory tile (or bit). At the second zoom level a quadtree tile will
  # represent 4 memory tiles, and so on.
  # For more details: http://en.wikipedia.org/wiki/Quadtree
  # Note that there is the added complexity that a single address is byte_size-times wide, so unfortunately
  # a single address can never exactly represent a single quadtree tile.
  def quadtree_tiles(_zoom, quadx, quady)
    # When zoom == 20
    address_int = (dimensions[:x] * quady) + quadx
    address_bin = HumanComputer::Processor.eight_bitify address_int
    [Address.find_by(pid: @pid, address: address_bin)]
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
