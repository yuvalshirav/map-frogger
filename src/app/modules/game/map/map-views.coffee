@App.module "GameModule.Map", (Map, App, Backbone, Marionette, $, _) ->

  class Map.Car extends App.Views.ItemView
    CAR_COLORS = ['red', 'purple', 'blue']
    className: ->
      "car " + _.sample(CAR_COLORS)
    template: "game/map/car"
    modelEvents:
      pathDone: ->
        @trigger('pathDone', @model)

    onShow: ->
      @model.start()
      @model.setElement(@$el)

  class Map.MapView extends App.Views.CompositeView
    className: "map-view"
    template: "game/map/map-view"
    bindings: 'data-bind'
    model: new Backbone.DeepModel()
    modelEvents:
      'change:status': 'onStatusChange'

    childView: Map.Car
    childViewContainer: "#map-wrapper"
    childEvents:
      pathDone: 'onCarExit'

    ui:
      map: '#map'
      frog: '#frog'

    KEY_CODES =
      UP: 38
      DOWN: 40
      LEFT: 37
      RIGHT: 39
      SPACE: 32
      ESC: 27

    GAME_STATUSES =
      SPLASH: 'splash'
      PLAYING: 'playing'
      YOU_WIN: 'you-win'
      GAME_OVER: 'game-over'

    TRAFFIC_LIGHT_STATUSES =
      GREEN: 'green'
      YELLOW: 'yellow'
      RED: 'red'

    initialize: ({@center, @zoom, @frogStart, @frogTarget, @directions, @settings}) ->
      @collection = new Backbone.Collection()
      @model.set(status: GAME_STATUSES.SPLASH, orientation: App.Utils.getOrientation(), trafficLight1: 'red', trafficLight2: 'red')

      @setupPageVisibilityHandling()

    onRender: ->
      @map = new google.maps.Map @$('#map')[0],
        center: @center
        zoom: @zoom
        disableDefaultUI: true
        disableDoubleClickZoom: true
        draggable: false
        keyboardShortcuts: false
        scrollWheel: false
        zoomControl: false

      # map loaded
      google.maps.event.addListenerOnce(@map, 'idle', => @initGame())

      @initOrientationListener()

    onShow: ->
      @worldHeight = @ui.map.height()
      @worldWidth = @ui.map.width()
      @worldPosition = @ui.map.position()

    calibrateMap: ->
      mapOverlay = new google.maps.OverlayView()
      mapOverlay.draw = ->
      mapOverlay.setMap(@map)
      @mapProjection = mapOverlay.getProjection()

    initGame: ->
      @calibrateMap()

      for direction in @directions
        overviewPath = direction.get('routes')[0].overview_path # TODO handle missing/broken data
        direction.pixelPath = (@latLngToXY(latLng) for latLng in overviewPath)

        @initTrafficLight(direction)
        @initPath(direction)

      @initFrog()

      if App.Utils.isMobileOrTablet()
        @initTouchListener()
      else
        @initKeyboardListener()

      @trafficLightControl()
      @step()

    step: =>
      if @model.get('status') == GAME_STATUSES.PLAYING
        @animate(@frog, false)
        if @isGameWon()
          @gameWon()

      @collection.each (car) =>
        car.mindTraffic(@getNextCar(car), @model)

        unless car.isStopped()
          @animate(car)
        if @model.get('status') == GAME_STATUSES.PLAYING
          if car.isCollidingWith(@frog)
            @gameOver()

      if App.Utils.isMobileOrTablet()
        # TODO consider testing initial FPS, then decide whether requestAnimationFrame or best-effort setTimeout
        setTimeout(@step, 1000/60)
      else
        requestAnimationFrame(@step)

    onStatusChange: (model, status) ->
      if @frog
        @animate(@frog, false, if status == GAME_STATUSES.GAME_OVER then 2 else 1)

    getNextCar: (car) ->
      # TODO cache nextCar/prevCar better, as a model property
      car.nextCar ||= do =>
        carIndex = @collection.indexOf(car)
        directions = car.get('directions')
        nextCar = _.find @collection.first(carIndex).reverse(), (c) ->
          c.get('directions') == directions
        nextCar?.prevCar = car
        nextCar
      car.nextCar

    animate: (mover, withAngle=true, scale=1) ->
      point = mover.get('point')
      transform = "translate(#{Math.round(point.x)}px, #{Math.round(point.y)}px) scale(#{scale})"
      if withAngle
        angle = Math.round(mover.get('angle'))
        transform += " rotate(#{angle}deg)"
      mover.get('element').css(transform: transform, '-webkit-transform': transform, '-moz-transform': transform)

    isGameWon: ->
      won = false
      @satResponse ?= new SAT.Response()
      # TODO allow polygon targets
      if SAT.testPolygonCircle(@frog.getPolygon(), @frogTarget, @satResponse)
        won = @satResponse.aInB
      @satResponse.clear()
      return won

    initKeyboardListener: ->
      $(document).on 'keydown', (event) =>
        switch @model.get('status')
          when GAME_STATUSES.SPLASH then @startGame() if event.keyCode == KEY_CODES.SPACE
          when GAME_STATUSES.GAME_OVER then @resetGame() if event.keyCode == KEY_CODES.SPACE
          when GAME_STATUSES.YOU_WIN then @resetGame() if event.keyCode == KEY_CODES.SPACE
          when GAME_STATUSES.PLAYING then @handlePlayerAction(event)

    initTouchListener: ->

      $('#map-wrapper').on 'touchstart', =>
        App.Utils.requestFullScreen()

      $('button.play').on 'click', (event) =>
        switch @model.get('status')
          when GAME_STATUSES.SPLASH then @startGame()
          when GAME_STATUSES.GAME_OVER then @resetGame()
          when GAME_STATUSES.YOU_WIN then @resetGame()
        event.stopImmediatePropagation()

      $('#map-wrapper').swipe
        threshold: 25
        allowPageScroll: "none"
        swipe:  (event, direction, distance, duration, fingerCount, fingerData) =>
          return unless @model.get('status') == GAME_STATUSES.PLAYING
          d = switch direction
            when "left" then KEY_CODES.LEFT
            when "right" then KEY_CODES.RIGHT
            when "up" then KEY_CODES.UP
            when "down" then KEY_CODES.DOWN
          @moveFrog(d, Math.max(1, distance*1.5/duration))
          event.preventDefault()
          event.stopImmediatePropagation()


    startGame: ->
      @model.set('status', GAME_STATUSES.PLAYING)

    gameOver: ->
      @model.set('status', GAME_STATUSES.GAME_OVER)

    resetGame: ->
      @initFrog()
      @model.set('status', GAME_STATUSES.SPLASH)

    gameWon: ->
      @model.set('status', GAME_STATUSES.YOU_WIN)

    handlePlayerAction: (event) ->
      return unless @model.get('status') == GAME_STATUSES.PLAYING
      if event.keyCode in [KEY_CODES.UP, KEY_CODES.DOWN, KEY_CODES.LEFT, KEY_CODES.RIGHT]
        @moveFrog(event.keyCode)
        event.preventDefault()
        event.stopImmediatePropagation()

    initTrafficLight: (directions) ->
      trafficLight = directions.get('trafficLight')
      return unless trafficLight
      originXY = @latLngToXY(directions.get('origin'))
      trafficLightXY = @latLngToXY(trafficLight.location)
      initialStatus = if @model.get("trafficLights.#{trafficLight.pairedWith}.status") == TRAFFIC_LIGHT_STATUSES.GREEN then TRAFFIC_LIGHT_STATUSES.RED else TRAFFIC_LIGHT_STATUSES.GREEN
      @model.set "trafficLights.#{trafficLight.id}",
        id: trafficLight.id
        percent: trafficLight.percent
        location: trafficLightXY
        xDirection: trafficLight.xDirection
        yDirection: trafficLight.yDirection
        pairedWith: trafficLight.pairedWith
        status: initialStatus

      # workaround due to lack of Epoxy support for DeepModel
      @model.set("trafficLight#{trafficLight.id}", initialStatus)
      @model.on "change:trafficLights.#{trafficLight.id}.status", (model, status) =>
        @model.set("trafficLight#{trafficLight.id}", status)


    # TODO parmaterize timeouts
    trafficLightControl: =>
      model = @model
      greenLights = _.where(_.values(model.get('trafficLights')), status: 'green')
      promises = _.map greenLights, (greenLight) ->
        new RSVP.Promise (resolve) =>
          model.set("trafficLights.#{greenLight.id}.status", TRAFFIC_LIGHT_STATUSES.YELLOW)
          setTimeout =>
            model.set("trafficLights.#{greenLight.id}.status", TRAFFIC_LIGHT_STATUSES.RED)
            setTimeout =>
              model.set("trafficLights.#{greenLight.pairedWith}.status", TRAFFIC_LIGHT_STATUSES.GREEN)
              resolve()
            , 200
          , 1000
      RSVP.all(promises).then =>
        setTimeout(@trafficLightControl, 5000)

    initPath: (directions) ->
      @spawnInitialPathCars(directions)
      @spawnPathCars(directions)

    spawnInitialPathCars: (directions, n=5) ->
      percents = ((10 + Math.random() * 90) for i in [0...n])
      percents = percents.sort (a, b) ->
        b - a
      for percent in percents
        car = new App.Entities.Car(path: directions.pixelPath, percent: percent, directions: directions, speed: @settings.CAR_SPEED, restart: false, withAngle: true, offset: {x: -12, y: -6})
        car.start()
        car.mindTraffic(@getNextCar(car), @model)
        unless car.isStopped()
          @collection.add(car)

    spawnPathCars: (directions) ->
      @spawnCar(directions)
      setTimeout =>
        @spawnPathCars(directions)
      , @settings.MIN_CAR_SPAWN_MS + Math.random()*(@settings.MAX_CAR_SPAWN_MS - @settings.MIN_CAR_SPAWN_MS)

    spawnCar: (directions) ->
      lastCar = @collection.where(directions: directions).sort().pop()
      unless lastCar?.getPercent() < 8 # TODO
        car = new App.Entities.Car(path: directions.pixelPath, directions: directions, speed: @settings.CAR_SPEED, restart: false, withAngle: true, offset: {x: -12, y: -6})
        @collection.add(car)

    onCarExit: (view, car) ->
      @collection.remove(car)
      car.prevCar?.nextCar = null

    initFrog: ->
      @frogHeight = @ui.frog.height()
      @frogWidth = @ui.frog.width()
      # TODO no need for both point and path
      @frog = new App.Entities.Mover(path: [@frogStart], point: @frogStart, speed: @settings.FROG_SPEED, withAngle: false, bounds: {left: 0, top: 0, right: @worldWidth, bottom: @worldHeight})
      @frog.setElement(@ui.frog)

    moveFrog: (direction, multiplier=1) ->
      return unless @frog.isStopped()
      d = switch direction
        when KEY_CODES.UP then {x: 0, y: -multiplier}
        when KEY_CODES.DOWN then {x: 0, y: multiplier}
        when KEY_CODES.LEFT then {x: -multiplier, y: 0}
        when KEY_CODES.RIGHT then {x: multiplier, y: 0}
      d = _.mapObject d, (v) => v * @settings.FROG_JUMP
      @frog.addMoveBy(d)

    # TODO some of this can be cached, though not really a bottleneck
    latLngToXY: (latLng) =>
      topRight = @map.getProjection().fromLatLngToPoint(@map.getBounds().getNorthEast())
      bottomLeft = @map.getProjection().fromLatLngToPoint(@map.getBounds().getSouthWest())
      scale = Math.pow(2, @map.getZoom())
      worldPoint = @map.getProjection().fromLatLngToPoint(latLng)
      new google.maps.Point((worldPoint.x - bottomLeft.x) * scale, (worldPoint.y - topRight.y) * scale);

    setupPageVisibilityHandling: ->
      $(document).on 'show', =>
        if @hidden
          @hidden = false
          @collection.reset()
          for direction in @directions
            @spawnInitialPathCars(direction)

      $(document).on 'hide', =>
        @hidden = true

    # orientation media queries are quirky when used specific dimensions in viewport meta-tag
    initOrientationListener: ->
      $(window).on 'orientationchange', (event) =>
        @model.set('orientation', App.Utils.getOrientation())
        if @model.get('status') == GAME_STATUSES.PLAYING
          @model.set('status', GAME_STATUSES.SPLASH)

  class Map.LoadingView extends App.Views.ItemView
    className: "loading-view"
    template: "game/map/loading-view"

    onShow: ->
      new Spinner(scale: 2).spin(@el)

