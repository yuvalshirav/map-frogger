@App.module "GameModule.Map", (Map, App, Backbone, Marionette, $, _) ->

  class Map.Controller extends App.Controllers.Application

    GAME_SETTINGS =
      FROG_SPEED: 150
      FROG_JUMP: 16
      CAR_SPEED: 100
      MIN_CAR_SPAWN_MS: 500
      MAX_CAR_SPAWN_MS: 1500

    GAME_SCENARIOS =
      TLV: ->
        center: new google.maps.LatLng(32.083928341394426, 34.7827585)
        zoom: 15
        trafficLightCycle: 5000
        frogStart: {x: 20, y: 240}
        frogTarget: new SAT.Circle(new SAT.Vector(431, 72), 25)
        paths: [
            origin: new google.maps.LatLng(32.0890465, 34.7902409)
            destination: new google.maps.LatLng(32.0857560, 34.7947792)
            waypoints: [{location: new google.maps.LatLng(32.0879921, 34.7898440)}, {location: new google.maps.LatLng(32.0864832,34.7883848)}, {location: new google.maps.LatLng(32.0858832, 34.7908203)}]
            travelMode: google.maps.TravelMode.DRIVING
          ,
          origin: new google.maps.LatLng(32.0715260, 34.7818210) # TODO calibrate this route
          destination: new google.maps.LatLng(32.0963290, 34.7836960)
          travelMode: google.maps.TravelMode.DRIVING
          trafficLight:
            id: 1
            location: new google.maps.LatLng(32.0850653, 34.7817492)
            pairedWith: 2
            yDirection: -1
            percent: 57
        ,
          origin: new google.maps.LatLng(32.0852052, 34.7708178)
          destination: new google.maps.LatLng(32.0783328, 34.7800017)
          travelMode: google.maps.TravelMode.DRIVING
        ,
          origin: new google.maps.LatLng(32.0870651, 34.7704196),
          destination: new google.maps.LatLng(32.0835745, 34.7947955)
          travelMode: google.maps.TravelMode.WALKING
          trafficLight:
            id: 2
            location: new google.maps.LatLng(32.0853562, 34.7814703)
            pairedWith: 1
            xDirection: 1
            percent: 43
        ]

    initialize: ->
      @show(new Map.LoadingView())
      App.Utils.loadGoogleMaps().then(@start)

    start: =>
      scenario = GAME_SCENARIOS.TLV()
      directionPromises = _.map scenario.paths, (path) ->
        direction = new App.Entities.Directions(path)
        direction.fetch()
      RSVP.all(directionPromises).then (directions) =>
        @show new Map.MapView(center: scenario.center, zoom: scenario.zoom, frogStart: scenario.frogStart, frogTarget: scenario.frogTarget, directions: directions, settings: GAME_SETTINGS)
