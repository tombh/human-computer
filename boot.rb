def recursive_require(folder)
  Dir["#{HumanComputer.root}/#{folder}/**/*.rb"].each { |f| require f }
end

ENV['HC_ENV'] ||= 'development'
ENV['RACK_ENV'] = ENV['HC_ENV']

require 'rubygems'
require 'bundler/setup'
Bundler.require :default, ENV['HC_ENV']

require 'English'

I18n.enforce_available_locales = false

require_relative './lib/human_computer'

Mongoid.load!(HumanComputer.root + '/config/mongoid.yml')

# Add the project path to Ruby's library path for easy require()'ing
$LOAD_PATH.unshift(HumanComputer.root)
recursive_require 'lib'
recursive_require 'api'
