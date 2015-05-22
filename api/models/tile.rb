module HumanComputer
  # A human-drawn boolean bit. These make up the memory
  class Tile
    include Mongoid::Document

    belongs_to :memory

    # JSON array of paths
    field :paths
  end
end
