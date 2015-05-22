HumanComputer.recursive_require 'api/routes'

# Base Grape class
class API < Grape::API
  version :v1, using: :accept_version_header
  format :json
  prefix :api
  rescue_from :all

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
    { 'version' => HumanComputer::VERSION }
  end

  desc 'WIP'
  params do
    requires :paths
  end
  post '/tile' do
    tile = HumanComputer::Tile.first || HumanComputer::Tile.create
    tile.data = params[:paths]
    tile.save!
  end

  desc 'dasdasda'
  get '/tile' do
    HumanComputer::Tile.first.data
  end

  mount Routes::Process

  add_swagger_documentation
end
