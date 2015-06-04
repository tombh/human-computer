TileRenderer = require 'lib/tile_renderer'
Process = require 'models/process'

describe 'Tile Renderer', ->
  beforeEach ->
    @process = new Process 1
    @process.size = 128
    @process.details = {
      byte_size: 8,
      memory: {
        dimensions: {
          x: 88,
          y: 11
        }
      }
    }

    memoryMap = {
      process: @process,
      tiles: {},
      maxZoom: 20,
      tileSize: 150
    }

    @tiler = new TileRenderer memoryMap

    @ctx = jasmine.createSpyObj 'getContext', [
      'lineWidth',
      'lineJoin',
      'strokeSttyle',
      'beginPath',
      'moveTo',
      'lineTo',
      'stroke'
    ]
    @canvas = {
      getContext: =>
        @ctx
    }

    @mockTileRequest = (x, y, zoom) ->
      tilePoint = {
        x: x,
        y: y
      }
      zoom = zoom
      @tiler.renderer(@canvas, tilePoint, zoom)

  describe 'Bit calculator', ->
    # Only create stubs for these more unit-style tests
    beforeEach ->
      @process.fetchBits = jasmine.createSpy 'fetchBits'
      @tiler.renderTile = jasmine.createSpy 'renderTile'

    describe 'At highest zoom', ->
      it 'should fetch the top left bit', ->
        @mockTileRequest(0, 0, 20)
        bits = @tiler.requiredMemoryBits()
        expect(bits).toEqual [0]

      it 'should fetch the second bit', ->
        @mockTileRequest(1, 0, 20)
        bits = @tiler.requiredMemoryBits()
        expect(bits).toEqual [1]

      it 'should fetch the second bit of the second row', ->
        @mockTileRequest(1, 1, 20)
        bits = @tiler.requiredMemoryBits()
        expect(bits).toEqual [89]

      it 'should fetch the last bit of the last row', ->
        @mockTileRequest(87, 10, 20)
        bits = @tiler.requiredMemoryBits()
        expect(bits).toEqual [967]

    describe 'At second highest zoom', ->
      it 'should fetch the top left bits', ->
        @mockTileRequest(0, 0, 19)
        bits = @tiler.requiredMemoryBits()
        expect(bits).toEqual [0, 1, 88, 89]

      it 'should fetch the top left bits, across 1', ->
        @mockTileRequest(1, 0, 19)
        bits = @tiler.requiredMemoryBits()
        expect(bits).toEqual [2, 3, 90, 91]

      it 'should fetch the top left bits, across 1 and down 1', ->
        @mockTileRequest(1, 1, 19)
        bits = @tiler.requiredMemoryBits()
        expect(bits).toEqual [178, 179, 266, 267]

  describe 'Address calculator', ->
    it 'should only fetch the 1st address for the first bits', ->
      bits = [0, 1, 2, 3, 4]
      addresses = @tiler.bitsToAddresses bits
      expect(addresses).toEqual ['0']

    it 'should fetch the 1st and 2nd addresses', ->
      bits = [0, 8]
      addresses = @tiler.bitsToAddresses bits
      expect(addresses).toEqual ['0', '1']

    it 'should fetch deep addresses', ->
      bits = [89, 450, 967]
      addresses = @tiler.bitsToAddresses bits
      expect(addresses).toEqual ['11', '56', '120']

  it 'should fetch uncached addresses', ->
    @tiler.process.memory.tiles = { '00000000': [], '00001101': [] }
    addressesToFetch = @tiler.missingAddresses [0, 1, 13, 43]
    expect(addressesToFetch).toEqual [ '00000001', '00101011' ]

  describe 'Path transformation', ->
    it 'should not transform paths at max zoom', ->
      @tiler.scaleFactor = 1
      paths = [[0, 0], [10, 10]]
      index = 0
      transformed = @tiler.transformPaths(paths, index)
      expect(transformed).toEqual paths

    it 'should shrink and offset', ->
      @tiler.scaleFactor = 2
      paths = [[10, 10]]
      index = 0
      transformed = @tiler.transformPaths(paths, index)
      expect(transformed).toEqual [[5, 5]]
      index = 1
      transformed = @tiler.transformPaths(paths, index)
      expect(transformed).toEqual [[80, 5]]
      index = 2
      transformed = @tiler.transformPaths(paths, index)
      expect(transformed).toEqual [[5, 80]]
      index = 3
      transformed = @tiler.transformPaths(paths, index)
      expect(transformed).toEqual [[80, 80]]

  it 'should draw a tile', ->
    # Created with
    # { addresses: [{ address: '00000000', tiles: [{ bit: 1, paths: [[11, 11], [20, 20]] }] }] }
    @mockTileRequest(0, 0, 20)
    @tiler.renderTile()
    SpecHelpers.ajaxResponse({
      decompressedSize: 66,
      base64EncodedCompressedJSON: 'q1ZKTEkpSi0uTi1WsoquhvGUrJQMoEBJR6kkM' +
                                   'wcsHR1taKBjaBCrE21koGNk\nEBsbWxtbCwA='
    })
    expect(@ctx.moveTo).toHaveBeenCalledWith 10, 10
    expect(@ctx.lineTo).toHaveBeenCalledWith 20, 20
