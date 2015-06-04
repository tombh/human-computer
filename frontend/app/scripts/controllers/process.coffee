m = require 'mithril'
Process = require 'models/process'
ApplicationController = require 'controllers/application'

class ProcessController extends ApplicationController
  constructor: ->
    super
    @process = new Process m.route.param 'pid'

module.exports = ProcessController
