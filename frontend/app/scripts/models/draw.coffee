# Handle the drawing to the canvas of a tile
class Draw
  @lineWidth: 10
  @lineJoin: 'round'
  @lineColour: 'purple'

  @getMousePos: (canvas, evt) ->
    rect = canvas.getBoundingClientRect()
    {
      x: +(evt.clientX - rect.left).toFixed(2),
      y: +(evt.clientY - rect.top).toFixed(2)
    }

  # Mithril config function
  @draw: (element, isInitialized, context) ->

    # don't redraw if we did once already
    return if (isInitialized)

    ctx = element.getContext '2d'
    ctx.beginPath()
    ctx.lineWidth = @lineWidth
    ctx.lineJoin = ctx.lineCap = @lineJoin
    ctx.strokeStyle = @lineColour
    save = []
    @isDrawing

    element.onmousedown = (event) ->
      @isDrawing = true
      pos = Draw.getMousePos(element, event)
      ctx.moveTo(pos.x, pos.y)
      save.push([pos.x, pos.y])

    element.onmousemove = (event) ->
      if @isDrawing
        pos = Draw.getMousePos(element, event)
        save.push([pos.x, pos.y])
        ctx.lineTo(pos.x, pos.y)
        ctx.stroke()

    element.onmouseup = ->
      save.push(false)
      localStorage.path = JSON.stringify(save)
      @isDrawing = false

  @renderTile: (tile) ->
    (element, isInitialized, context) ->
      # don't redraw if we did once already
      return if (isInitialized)

      ctx = element.getContext '2d'
      ctx.lineWidth = @lineWidth
      ctx.lineJoin = ctx.lineCap = @lineJoin
      ctx.strokeStyle = @lineColour
      up = true
      tile.paths.forEach (path) ->
        up = true unless path
        if up
          ctx.beginPath()
          ctx.moveTo(path[0], path[1])
          up = false
        else
          ctx.lineTo(path[0], path[1])
          ctx.stroke()

module.exports = Draw
