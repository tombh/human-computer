Memory = require 'models/memory'

class Process
  constructor: (pid) ->
    @memory = new Memory pid

module.exports = Process
