m = require 'mithril'
Tile = require 'models/tile'
tile = require 'views/partials/tile'

module.exports = (controller) ->
  [
    m '.container', [
      m 'h1', 'home'
      controller.bytes().map (bit) ->
        tile(bit)
    ],
  ]
