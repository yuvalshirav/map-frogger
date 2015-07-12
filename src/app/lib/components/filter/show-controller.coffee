# Show Controller
#
# This controller will handle everything related to the "show" action
# of the `Filter` component.
@App.module "Components.Filter", (Filter, App, Backbone, Marionette, $, _) ->

  class Filter.Controller extends App.Controllers.Application
    initialize: (options) ->
      @options = options

      # Retrieves the `FilterView` and set it as the "main view" of the
      # controller
      view = @getFilterView(options)
      @setMainView view

      # whenever filter text changes, any listener of this component
      # will be notified
      @listenTo view, "filter:text:changed", (text) =>
        if (text isnt options.filter)
          @trigger "filter:text:changed", text

        options.filter = text

      # when it first show, update its listener with its own state
      @listenTo view, "show", ->
        @trigger "filter:text:changed", options.filter or ""

    getFilterView: (options) ->
      new Filter.FilterView options

  # Creates a `filter:component` request, which instances and return
  # a new `Filter` component. This is the way to use the component, requesting
  # it.
  App.reqres.setHandler "filter:component", (options) ->
    new Filter.Controller options

