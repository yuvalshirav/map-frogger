# # Show Controller
#
# This controller will handle everything related to the "show"
# action of the `Header` module.
@App.module "HeaderModule.Show", (Show, App, Backbone, Marionette, $, _) ->

  # Extends `App.Controllers.Application`, which in the end
  # is nothing but a custom extension of `Marionette.Controller`.
  class Show.Controller extends App.Controllers.Application

    # ##  Initialize
    #
    # Shows an instance of a `Show.HeaderView` on the
    # module default region, which is `App.headerRegion`
    # as it was passed on the instantiation of the Controller
    # on [HeaderModule](../header.html#show)
    initialize: ->
      headerView = @getHeaderView()
      @show headerView

    # ## getHeaderView
    #
    # Creates and return a new instance of `Show.HeaderView`
    getHeaderView: ->
      new Show.HeaderView()
