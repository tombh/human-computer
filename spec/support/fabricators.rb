Fabricator :pid do
  id 1
  byte_size 8
  memory_class PersistedMemory
  addresses(count: 3) do |attrs, i|
    i -= 1
    address = HumanComputer::Processor.eight_bitify i
    Fabricate(:address, id: i, pid_id: attrs[:id], address: address)
  end
end

Fabricator :address do
  id 1
  address '00000000'
  tiles(count: 8) { |attrs, _i| Fabricate(:tile, address_id: attrs[:id]) }
end

Fabricator :tile do
  paths JSON.generate [[10, 10], [20, 20]]
end
