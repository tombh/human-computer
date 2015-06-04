# Serialise address objects
# Currently renders like;
# { addresses: [{ address: '00000000', tiles: [ [[10, 10], [20, 20]] ] } ] }
module AddressRepresenter
  include Roar::JSON
  include Roar::Hypermedia
  include Grape::Roar::Representer

  collection :entries, as: :addresses do
    property :address
    def tiles_merged
      tiles.map! { |tile| ::JSON.parse(tile.paths) }
    end
    collection :tiles_merged, as: :tiles
  end
end
