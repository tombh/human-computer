m = require 'mithril'
Draw = require 'models/draw'

module.exports = (tile) ->
  m 'canvas', { height: '120', width: '120', config: Draw.renderTile(tile) }
