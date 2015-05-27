m = require 'mithril'
Tile = require 'models/tile'
tile_partial = require 'views/partials/tile'
L = require 'leaflet'

map = (element, isInitialized, context) ->
  return if isInitialized

  # create a map in the "map" div, set the view to a given place and zoom
  map = L.map('container', {
    crs: L.CRS.Simple
  })

  southWest = map.unproject([0, 6145], map.getMaxZoom())
  northEast = map.unproject([1024, 0], map.getMaxZoom())
  map.setMaxBounds(new L.LatLngBounds(southWest, northEast))

  canvasTiles = L.tileLayer.canvas({
    maxZoom: 20,
    minZoom: 16,
    maxNativeZoom: 20,
    continuousWorld: true,
    noWrap: true
    }).addTo(map)

  canvasTiles.drawTile = (canvas, tilePoint, zoom) ->
    console.log tilePoint, zoom
    ctx = canvas.getContext('2d')
    ctx.beginPath()
    ctx.rect(0, 0, 256, 256)
    ctx.lineWidth = 2
    ctx.strokeStyle = 'white'
    ctx.stroke()

    ctx.font="20px Arial"
    ctx.fillStyle = 'white'
    ctx.fillText(tilePoint.x + " / " + tilePoint.y + " / " + zoom, 80, 140)

  map.setView([0, 0], 18)

module.exports = (controller) ->
  [
    m '#container', {config: map}
    # [
    #   m 'h1', 'Home'
    #   controller.bytes().map (bit) ->
    #     tile_partial(bit)
    # ],
  ]
