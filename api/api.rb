HumanComputer.recursive_require 'api/routes'

# Base Grape class
class API < Grape::API
  version :v1, using: :accept_version_header
  format :json
  formatter :json, Grape::Formatter::Roar
  prefix :v1
  # rescue_from :all do |e|
  #   error!("rescued from #{e.class.name}")
  # end

  helpers do
    def authenticate!(_level)
    end
  end

  desc 'About the API'
  get '/' do
    'Human Computer API'
  end

  desc 'API version'
  get '/version' do
    { version: HumanComputer::VERSION }
  end

  mount Routes::Process

  add_swagger_documentation
end
