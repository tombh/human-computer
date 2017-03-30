require 'spec_helper'

describe API do
  include Rack::Test::Methods

  def app
    API
  end

  describe Routes::Process do
    before do
      Fabricate :pid, id: 1, name: 'thing'
    end

    it 'should return tile data for addresses' do
      options = {
        addresses: [0, 1],
        uncompressed: true
      }
      get '/v1/process/thing/memory', options

      expect(last_response.status).to eq 200
      response = JSON.parse(last_response.body)['addresses']
      expect(response[0]['address']).to eq '00000000'
      expect(response[0]['tiles'].first).to eq [[10, 10], [20, 20]]
      expect(response[1]['address']).to eq '00000001'
      expect(response[1]['tiles'].first).to eq [[10, 10], [20, 20]]
    end

    it 'should return all tile data' do
      options = {
        addresses: ['all'],
        uncompressed: true
      }
      get '/v1/process/thing/memory', options

      expect(last_response.status).to eq 200
      response = JSON.parse(last_response.body)['addresses']
      expect(response.count).to eq 3
    end
  end
end
