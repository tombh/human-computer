api = require 'models/api'
Draw = require 'models/draw'

class Tile
  @savePath: (_event) ->
    api.post 'tile', { paths: localStorage.path }, (_result) ->
      api.message 'Serialised'

  @getPath: (event) ->
    element = document.getElementById('c2')
    api.get 'tile', {}, (result) ->
      api.message 'Rendering...'
      Draw.renderTile element, JSON.parse(result)

module.exports = Tile
