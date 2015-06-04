require_relative 'processor'

module HumanComputer
  # Th human processor represents human actions, so there should be very little here
  class HumanProcessor < Processor
    def self.boot(program)
      processor = new PersistedMemory
      processor.boot program
    end
  end
end
