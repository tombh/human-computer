# Serialise memory objects
module MemoryRepresenter
  include Roar::JSON
  include Roar::Hypermedia
  include Grape::Roar::Representer

  property :dimensions
  property :usage
end
