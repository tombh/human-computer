module HumanComputer
  VERSION = '0.0.1'

  def self.recursive_require(folder)
    Dir["#{HumanComputer::Config.root}/#{folder}/**/*.rb"].each { |f| require f }
  end

  # Config for the whole Human Computer app
  class Config
    class << self
      # Root path of the project on the host filesystem
      def root
        File.join(File.dirname(__FILE__), '../')
      end
    end
  end
end
