# A human-drawn boolean bit. These make up the memory
class Tile
  include Mongoid::Document

  belongs_to :address

  # JSON array of paths
  field :paths
end
