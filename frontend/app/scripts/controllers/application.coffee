api = require 'models/api'

class ApplicationController
  constructor: ->
    @api = api

module.exports = ApplicationController
