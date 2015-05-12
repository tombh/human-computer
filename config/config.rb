module HumanComputer
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
