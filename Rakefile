require 'rubygems'
require 'bundler'

ENV['RACK_ENV'] ||= 'development'

begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts 'Run `bundle install` to install missing gems'
  exit e.status_code
end

require 'rake'

task :boot do
  require File.expand_path('../boot', __FILE__)
end

desc 'Run pry console'
task :console do |_t, _args|
  exec 'pry -r ./boot'
end

desc 'Initialise a program into memory'
task load: :boot do
  HumanComputer::HumanProcessor.boot 'add'
end
