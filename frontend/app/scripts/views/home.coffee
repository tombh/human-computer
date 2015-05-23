m = require 'mithril'
Tile = require 'models/tile'
tile_partial = require 'views/partials/tile'

module.exports = (controller) ->
  [
    m '.container', [
      m 'h1', 'home'
      controller.bytes().map (bit) ->
        tile_partial(bit)
    ],
  ]
