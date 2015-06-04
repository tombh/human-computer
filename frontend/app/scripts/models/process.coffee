Model = require 'models/model'
Memory = require 'models/memory'

class Process extends Model
  constructor: (pid) ->
    super
    @pid = pid
    @memory = new Memory pid

  fetchDetails: ->
    @api.get("process/#{@pid}").then (response) =>
      @details = response
      @size = 2 ** (@details.byte_size - 1)
      # First initialise addresses to []
      for i in [0...@size]
        binaryAddress = @bitify i
        @memory.tiles[binaryAddress] = []
      @fetchBits 'all'

  fetchBits: (addresses) ->
    @api.getCompressed(
      "process/#{@pid}/memory",
      { 'addresses[]': addresses }
    ).then( (response) =>
      response.addresses.forEach (byte) =>
        @memory.tiles[byte.address] = byte.tiles
    ).then(null, (error) ->
      throw new Error error
    )

  # Convert an integer to a 0-padded binary string
  # Eg; 1 becomes '00000001'
  bitify: (int) ->
    Process._lpad parseInt(int).toString(2), @details.byte_size

  @_lpad: (n, width, z) ->
    z = z || '0'
    n = n + ''
    if n.length >= width
      n
    else
      new Array(width - n.length + 1).join(z) + n

module.exports = Process
