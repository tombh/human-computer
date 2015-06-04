m = require 'mithril'
memory_map = require 'lib/memory_map'

module.exports = (controller) ->
  [
    m '#memory_map', { config: memory_map.render(controller) }
  ]
