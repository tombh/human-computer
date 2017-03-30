m = require 'mithril'
Auth = require 'models/auth'
Decompress = require 'lib/decompress'

class API
  base = '/api/v1'

  constructor: ->
    @message = m.prop 'Loading...'

  get: (path, params) ->
    @request 'GET', path, params

  # same as @get() but assumes the response will have a compressed property that needs decompressing
  getCompressed: (path, params) ->
    @get(path, params).then((response) ->
      jsonString = Decompress.decompress(
        response.base64EncodedCompressedJSON,
        response.decompressedSize
      )
      JSON.parse jsonString
    ).then(null, (error) ->
      throw new Error error
    )

  post: (path, params) ->
    @request 'POST', path, params

  request: (method, path, params) ->
    options = {
      method: method,
      url: "#{base}/#{path}",
      data: params
    }
    @message 'Making API request'
    Auth.request(options).then (response) =>
      @message 'API request complete'
      response

module.exports = new API
