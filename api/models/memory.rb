module HumanComputer
  # Stores tiles (binary state) as locations on a 2D memory grid.
  # Each position on the grid has a binary reference and contains a bytes-worth of tiles
  class Memory
    include Mongoid::Document

    belongs_to :process
    has_many :tiles

    # In binary string form, eg; '01010101'
    field :address
  end
end
