L = require 'leaflet'
m = require 'mithril'
TileRenderer = require 'lib/tile_renderer'

class MemoryMap
  constructor: (element, process) ->
    @process = process
    @maxZoom = 20
    @minZoom = 16
    @tileSize = 150

    map = L.map(element.getAttribute('id'), {
      crs: L.CRS.Simple
    })

    # Calculate the size of the map
    x = @process.details.memory.dimensions.x * @tileSize
    y = @process.details.memory.dimensions.y * @tileSize
    # All the coords seem to need to be offset by 1 to fit properly, otherwise there's an extra
    # border of tiles.
    northEast = map.unproject([x - 1, 1], @maxZoom)
    southWest = map.unproject([1, y - 1], @maxZoom)
    bounds = new L.LatLngBounds(southWest, northEast)

    canvasTiles = L.tileLayer.canvas({
      maxZoom: @maxZoom,
      minZoom: @minZoom,
      # Zoom level at which CSS zooming occurs
      maxNativeZoom: @maxZoom,
      # Not sure, but apparently you need for non-geographic maps
      continuousWorld: true,
      # Don't wrap the world. So you can only pan around the map once
      noWrap: true,
      # The size of an individual tile in pixels
      tileSize: @tileSize,
      # Don't render tiles outside the bounds
      bounds: bounds
    }).addTo(map)

    tiler = new TileRenderer this
    # Leaflet.js calls the function here for every tile than needs to be drawn
    canvasTiles.drawTile = tiler.renderer

    # Don't let the user pan past these bounds
    map.setMaxBounds bounds
    # Where to centre the map
    map.setView([0, 0], 20)

  @render: (controller) ->
    (element, isInitialized, context) ->
      return if isInitialized
      # Need to make sure we have details about the process' memory first
      controller.process.fetchDetails().then( ->
        new MemoryMap element, controller.process
      ).then(null, (error) ->
        throw new Error error
      )

module.exports = MemoryMap
