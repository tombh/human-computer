module HumanComputer
  # Represents a running program
  class Process
    include Mongoid::Document

    has_one :memory

    # The size of a byte. Typically 8 bits per byte
    field :bits, type: Integer, default: 8
  end
end
