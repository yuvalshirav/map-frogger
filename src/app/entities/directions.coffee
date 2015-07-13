@App.module "Entities", (Entities, App, Backbone, Marionette, $, _) ->

  class Entities.Directions extends Entities.Model

    buildDirectionsRequest: ->
      origin: @get('origin')
      destination: @get('destination')
      waypoints: @get('waypoints')
      travelMode: @get('travelMode')

    sync: (method, model, options) ->
      # TODO only if method is 'read'
      new RSVP.Promise (resolve, reject) =>
        directionsService = new google.maps.DirectionsService()
        directionsService.route @buildDirectionsRequest(), (response, status) =>
          if status == google.maps.DirectionsStatus.OK
            options.success(response)
            resolve(@)
          else
            options.error(status)
            reject(status)
