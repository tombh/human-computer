m = require 'mithril'
Process = require 'models/process'
ApplicationController = require 'controllers/application'

class HomeController extends ApplicationController
  constructor: ->
    super
    @process = new Process 2
    @renderByte()

  renderByte: ->
    @bytes = @process.memory.getByte '00000000'

module.exports = HomeController
