@App.module "Entities", (Entities, App, Backbone, Marionette, $, _) ->

  class Entities.Car extends Entities.Mover

    mindTraffic: (nextCar, roads, offset) ->
      @stopCount ?= 0
      directions = @get('directions')
      trafficLight = roads.get("trafficLights.#{directions.get('trafficLight')?.id}")
      p = @get('point')

      if trafficLight && trafficLight.status != 'green' # TODO use a const here!
        if 0 < (trafficLight.percent - @getPercent()) <= 1
          @stop()
          return true
        else
          if @isStopped() && !@isColliding1d(nextCar)
            @continue()
            return false
      else
        if @isStopped() && !@isColliding1d(nextCar)
          @continue()
          return false
      if !@isStopped() && @isColliding1d(nextCar)
        @stop()
        return true
      return false

    isColliding1d: (nextCar, offset=@get('safetyOffset')) ->
      if nextCar
        return nextCar.getLocation1d() - nextCar.get('height') < @getLocation1d() + offset
      false