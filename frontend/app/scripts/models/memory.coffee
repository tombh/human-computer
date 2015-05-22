api = require 'models/api'

class Memory
  constructor: (pid) ->
    @pid = pid

  getByte: (address) ->
    api.get "process/#{@pid}/memory/#{address}"

module.exports = Memory
