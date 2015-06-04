# Render tiles on a Leaflet.js map
class TileRenderer
  constructor: (memoryMapInstance) ->
    @map = memoryMapInstance
    @process = @map.process
    @lineWidth = 2
    @lineJoin = 'round'
    @lineColour = 'purple'

  # Called by Leaflet.js every time a tile needs rendering.
  # By 'tile' we are referring to a map tile that may contain many memory bits.
  # TODO: In the API memory bits are called tiles, so consider distinguishing between map tiles
  # and memory tiles with different names.
  renderer: (canvas, tilePoint, zoom) =>
    @ctx = canvas.getContext('2d')
    # The x/y coords of the tile being rendered
    @tilePoint = tilePoint
    @zoom = zoom
    # Eg; so that a zoom level of 19 will have a scaleFactor of 2 and a zoom level of 18 will
    # have a scaleFactor of 4.
    @scaleFactor = 2 ** (@map.maxZoom - @zoom)
    @debuggingOverlay()
    @renderTile()

  renderTile: ->
    bits = @requiredMemoryBits()
    requiredAddresses = @bitsToAddresses bits
    addressesToFetch = @missingAddresses requiredAddresses
    if addressesToFetch.length
      @process.fetchBits(addressesToFetch).then( =>
        @renderBits(bits)
      ).then(null, (error) ->
        throw new Error error
      )
    else
      @renderBits(bits)

  renderBits: (bits) ->
    bits.forEach (bit, index) =>
      address = parseInt @singleBit2Address bit

      # Don't try ro render points on the map that are out of bounds of the memory
      return unless address < @process.size

      # Get the data for the address
      binaryAddress = @process.bitify address
      byte = @process.memory.tiles[binaryAddress]

      # If there's no data for an address then don't try and render it
      return unless byte.length

      # Position of the bit within a byte
      bitPos = bit - (@process.details.byte_size * address)

      paths = byte[bitPos]
      paths = @transformPaths paths, index

      # The actual drawing of stuff on the screen
      @strokeTile paths

  # Calculate all the memory bits that fit into this map tile. At a max zoom level of 20 a map
  # tile exactly represents a memory bit. As you zoom out, many memory bits can fit into a map
  # tile.
  # For every level of zoom outwards the map size dercreases by a factor or 2. Or you can think
  # of it as each map tile being able to fit in twice as many memory bits.
  requiredMemoryBits: ->
    # Calculate the bounds of the map tile in terms of the memory bits
    x1 = @tilePoint.x * @scaleFactor
    x2 = x1 + @scaleFactor
    y1 = @tilePoint.y * @scaleFactor
    y2 = y1 + @scaleFactor
    @getBitNumbersFromCoords x1, x2, y1, y2

  getBitNumbersFromCoords: (x1, x2, y1, y2) ->
    bits = []
    rowLength = @process.details.memory.dimensions.x
    for row in [y1...y2] by 1
      for col in [x1...x2] by 1
        # Bit numbers increment from 0 in the top-left to 2^byte-size in the bottom-right
        bitNumber = (row * rowLength - 1) + col + 1
        bits.push bitNumber
    bits

  # Fetch any missing memory bits from the API
  missingAddresses: (requiredAddresses) ->
    addressesToFetch = []
    # Remove out of bounds addresses
    requiredAddresses = requiredAddresses.filter( (address) =>
      address < @process.size
    )
    # Convert addresses to binary strings
    requiredAddresses = requiredAddresses.map( (address) =>
      @process.bitify address
    )
    requiredAddresses.forEach (address) =>
      # Note any adresses that aren't already in @process.memory.tiles
      addressesToFetch.push(address) unless @process.memory.tiles.hasOwnProperty(address)
    addressesToFetch

  # Given an array of bits, figure out which addresses they live in
  bitsToAddresses: (bits) ->
    bits.map( (bit) =>
      @singleBit2Address bit
    ).filter( (value, index, self) ->
      # Remove duplicate addresses
      self.indexOf(value) == index
    )

  # Find the byte within which the bit lives
  singleBit2Address: (bit) ->
    Math.floor(bit / @process.details.byte_size).toString()

  # Offset and shrink the paths, so that multiple bits can fit on a single tile
  transformPaths: (paths, index) ->
    pixelsPerTile = @map.tileSize / @scaleFactor
    yPos = Math.floor(index / @scaleFactor)
    xPos = index - (yPos * @scaleFactor)
    xShift = xPos * pixelsPerTile
    yShift = yPos * pixelsPerTile
    paths.map (path) =>
      return false unless path
      newX = (path[0] / @scaleFactor) + xShift
      newY = (path[1] / @scaleFactor) + yShift
      [newX, newY]

  # Actually draw lines on the tile's canvas
  strokeTile: (paths) ->
    @ctx.lineWidth = @lineWidth
    @ctx.lineJoin = @ctx.lineCap = @lineJoin
    @ctx.strokeStyle = @lineColour
    up = true # Pen is up so can't stroke
    paths.forEach (path) =>
      up = true unless path
      if up
        @ctx.beginPath()
        @ctx.moveTo(path[0], path[1])
        up = false
      else
        @ctx.lineTo(path[0], path[1])
        @ctx.stroke()

  # Renders info useful for debugging
  debuggingOverlay: ->
    return unless global.env == 'DEV'

    # Draw a border around the tile
    @ctx.beginPath()
    @ctx.rect(0, 0, @map.tileSize, @map.tileSize)
    @ctx.lineWidth = 2
    @ctx.strokeStyle = 'white'
    @ctx.stroke()

    # Write the tile's details in the tile
    @ctx.font = "15px Arial"
    @ctx.fillStyle = 'white'
    @ctx.fillText(@tilePoint.x + " / " + @tilePoint.y + " / " + @zoom, 35, 80)


module.exports = TileRenderer
