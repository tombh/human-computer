module HumanComputer
  # A human-drawn boolean bit. These make up the memory
  class Tile
    include Mongoid::Document

    # Serialized data, eg. Fabric.js JSON, or SVG, etc
    field :data
  end
end
