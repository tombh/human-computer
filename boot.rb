ENV['HC_ENV'] ||= 'development'
ENV['RACK_ENV'] ||= ENV['HC_ENV']

require 'rubygems'
require 'bundler/setup'
Bundler.require :default, ENV['HC_ENV']

require 'roar/representer'
require 'roar/json'
require 'roar/json/hal'

require 'English'

I18n.enforce_available_locales = false

require_relative './config/config'

Mongoid.load!(HumanComputer::Config.root + '/config/mongoid.yml')

# Add the project path to Ruby's library path for easy require()'ing
$LOAD_PATH.unshift(HumanComputer::Config.root)
HumanComputer.recursive_require 'lib'
HumanComputer.recursive_require 'api'
