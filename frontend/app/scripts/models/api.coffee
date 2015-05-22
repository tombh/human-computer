m = require 'mithril'
Auth = require 'models/auth'

class API
  base = 'http://localhost:9393/api'

  constructor: ->
    @message = m.prop('Ready...')

  get: (path, params) ->
    @request 'GET', path, params

  post: (path, params) ->
    @request 'POST', path, params

  request: (method, path, params) ->
    options = {
      method: method,
      url: "#{base}/#{path}",
      data: params
    }
    Auth.request(options)

module.exports = new API
