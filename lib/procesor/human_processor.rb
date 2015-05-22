module HumanComputer
  class HumanProcessor < Processor
    def self.boot(program)
      processor = self.new PersistedMemory
      processor.boot program
    end
  end
end
