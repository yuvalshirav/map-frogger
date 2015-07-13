@App.module "Entities", (Entities, App, Backbone, Marionette, $, _) ->

  class Entities.Mover extends Entities.Model

    defaults:
      percent: 0
      offset: {x: 0, y: 0}

    initialize:  ->
      # TODO init point
      @pathAnimator = new PathAnimator(Mover.createSVGPath(@get('path')))
      @set('point', @get('path')[0])
      @set('safetyOffset', 15 + Math.random() * 15)

    # TODO ?
    setElement: ($element) ->
      @set('element', $element)
      @set('width', $element.width())
      @set('height', $element.height())
      @setFrame()

    start: (restart) ->
      if restart || @isStopped()
        duration = @pathAnimator.path.getTotalLength() / @get('speed')
        @pathAnimator.start(duration, @step, @get('reverse'), @get('percent'), @pathDone, @get('easing'))

    step: (point, angle) =>
      if @get('withAngle')
        offset = @get('offset')
        point.x += offset.x
        point.y += offset.y
      @set(point: point, angle: angle)
      @setFrame()

    stop: ->
      @pathAnimator.stop()

    continue: ->
      @pathAnimator.continue()

    isStopped: ->
      @pathAnimator.stopped()

    setFrame: ->
      point = @get('point')
      return unless point
      width = @get('width')
      height = @get('height')
      @set('sat', new SAT.Box(new SAT.Vector(point.x, point.y), width, height))

    getPercent: ->
      return @pathAnimator.percent

    getPolygon: ->
      polygon = @get('sat').toPolygon()
      #if @get('withAngle')
      #  #polygon.setAngle((@get('angle')+270)*0.0174532925)
      #  polygon.rotate(-(@get('angle')+90)*0.0174532925)

    getCenter: ->
      p = @get('point')
      {x: Math.round(p.x + @get('width') / 2), y: Math.round(p.y + @get('height') / 2)}

    isCloseTo: (mover) ->
      p1 = @getCenter()
      p2 = mover.getCenter()
      return Math.abs(p1.x - p2.x) < @get('width') / 2 && Math.abs(p1.y - p2.y) < @get('height') / 2

    isCollidingWith: (mover) ->
      return unless @isCloseTo(mover)
      SAT.testPolygonPolygon(@getPolygon(), mover.getPolygon())

    addMoveBy: (d) ->
      currentTargetPoint = if @isStopped() then @get('point') else @getTargetPoint()
      bounds = @get('bounds')
      p =
        x: Math.min(Math.max(bounds.left, currentTargetPoint.x + d.x), bounds.right - @get('width'))
        y: Math.min(Math.max(bounds.top, currentTargetPoint.y + d.y), bounds.bottom - @get('height'))

      @addMoves([currentTargetPoint, p])

    addMoves: (points) ->
      if @isStopped()
        path = Mover.createSVGPath(points)
      else
        path = @pathAnimator.path.getAttribute('d')
        path += ' ' + Mover.createSVGPath(points)

      @pathAnimator.updatePath(path)
      @start()

    getLocation1d: ->
      @pathAnimator.location1d()

    getTargetPoint: ->
      path = @pathAnimator.path.getAttribute('d')
      [_, x, y] = path.match(/(\d+),(\d+)/)
      {x: parseInt(x, 10), y: parseInt(y, 10)}

    pathDone: =>
      if @get('restart')
        @start(true)
      else
        @trigger('pathDone', this)

    @createSVGPath: (pixelPath, firstCommand='M') ->
      d = ["#{firstCommand}#{pixelPath[0].x},#{pixelPath[0].y}"]
      for pixel in pixelPath[1..]
        d.push("L#{pixel.x},#{pixel.y}")
      d.join(' ')

