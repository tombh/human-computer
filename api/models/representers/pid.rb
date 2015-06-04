# Serialise pid objects
module PidRepresenter
  include Roar::JSON
  include Roar::Hypermedia
  include Grape::Roar::Representer

  property :id
  property :name
  property :created_at
  property :updated_at
  property :byte_size
  property :memory, extend: MemoryRepresenter
end
