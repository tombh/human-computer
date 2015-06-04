api = require 'models/api'

class Memory
  constructor: (pid) ->
    @pid = pid
    @tiles = {}

module.exports = Memory
