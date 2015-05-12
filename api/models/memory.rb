module HumanComputer
  # Stores tiles (binary state) as locations on a 2D memory grid.
  # Each position on the grid has a binary reference and contains a bytes-worth of tiles
  class Memory
    include Mongoid::Document

    belongs_to :process

    # All hash items have this structure: { location => [tile_id, tile_id, ...] }
    # Where 'location' is a string representation of a binary address
    field :grid, type: Hash
  end
end
