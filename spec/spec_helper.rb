ENV['RACK_ENV'] = 'test'

require 'codeclimate-test-reporter'
CodeClimate::TestReporter.start

require_relative '../boot'

Bundler.require :test
require 'rack/test'

Dir["#{HumanComputer::Config.root}/spec/support/**/*.rb"].each { |f| require f }

RSpec.configure do |c|
  c.mock_with :rspec
  c.expect_with :rspec
  c.color = true

  # Emtpy the DB
  c.before(:each) do
    Mongoid.default_session.drop
  end
end
