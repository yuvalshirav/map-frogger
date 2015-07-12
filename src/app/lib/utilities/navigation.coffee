# Navigation Utils
#
# All utils related to navigation.
@App.module "Utilities", (Utilities, App, Backbone, Marionette, $, _) ->

  _.extend App,

    # Set an autoInitHistory to true if not defined
    autoInitHistory: App.autoInitHistory or true

    # Methot to perform a navigation on the `Backbone.history`
    navigate: (route, options = {}) ->
      Backbone.history.navigate route, options

    # Get the current route on the `Backbone.history`
    getCurrentRoute: ->
      frag = Backbone.history.fragment
      if _.isEmpty(frag) then null else frag

    # Starts the `Backbone.history`
    startHistory: ->
      Backbone.history.start() if Backbone.history

  if App.autoInitHistory
    App.on "start", ->

      # Starts the Backbone History
      @startHistory()

      # Navigate to the `rootRoute` of the application if there is not an active
      # route
      @navigate(@rootRoute, trigger: true) unless @getCurrentRoute()

