# # Application Namespace
#
# Creates a global `App` object attached to the
# `window` to namespace our application.
@App = do (Backbone, Marionette) ->

  App = new Marionette.Application

  # Adds two application regions, one for
  # the header and one for the content.
  App.addRegions
    contentRegion: "#content"
    headerRegion : "#header"

  # Sets the default route. Our application will navigate
  # here if no route is provided on the URL.
  #
  # See: [navigation.coffee](navigation.html)
  App.rootRoute = ""

  # Creates an application global request to return the
  # default region. It will be used, for example, by
  # Controllers trying to show views without an specific
  # region provided.
  #
  # See: [application-controller.coffee](application-controller.html)
  App.reqres.setHandler "default:region", ->
    return App.contentRegion

  return App
