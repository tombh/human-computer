require_relative 'boot'

use Rack::Cors do
  allow do
    origins '*'
    resource '*', headers: :any, methods: :any
  end
end

map '/api' do
  run API
end

map '/' do
  use Rack::Static, urls: ['/assets'], root: 'frontend/build'
  run lambda { |_env|
    [
      200,
      {
        'Content-Type'  => 'text/html',
        'Cache-Control' => 'public, max-age=86400'
      },
      File.open('frontend/build/index.html', File::RDONLY)
    ]
  }
end
