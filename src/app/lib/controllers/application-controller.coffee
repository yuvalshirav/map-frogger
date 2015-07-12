# # Controllers
#
# Extends from `Marionette.Collection`. Is used as a wrapper in order to
# be able to add custom code to all `Controllers` on the application
# without modifying Marionette code directly.
@App.module "Controllers", (Controllers, App, Backbone, Marionette, $, _) ->

  class Controllers.Application extends Marionette.Controller

    constructor: (options = {}) ->

      # Set the Controllers region to the one passed as a parameter,
      # or using the application default region
      @region = options.region or App.request "default:region"
      super options

      # Store the controller instance on the registry
      @_instance_id = _.uniqueId("controller")
      App.execute "register:instance", @, @_instance_id

    close: ->
      console.log "closing", @ if App.request("app:option", "environment") is "dev"

      # Remove the closed instance from the registry
      App.execute "unregister:instance", @, @_instance_id
      super

    # Shows the given view on the controller region
    show: (view, options = {}) ->
      _.defaults options,
        region: @region

      # A controller could display another controller that could display a view.
      while view.getMainView then view = view.getMainView()

      if not view
        throw new Error("getMainView() did not return a view instance or #{view?.constructor?.name} is not a view instance")

      # Set the view as the "main view" of the controller
      @setMainView view

      # Show the view on controller region
      @_manageView view, options

    getMainView: ->
      @_mainView

    setMainView: (view) ->
      # Set the controller "main view" only if it not exist. The first
      # view shown by a controller is his "main view".
      return if @_mainView

      @_mainView = view

      # When the "main view" is closed, the controller is also closed
      @listenTo view, "destroy", @destroy

    _manageView: (view, options) ->
      options.region.show view
