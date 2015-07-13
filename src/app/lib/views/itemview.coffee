# # ItemView
#
# Extends from `Marionette.ItemView`. Is used as a wrapper
# in order to be able to add custom code to all `ItemView`
# on the application without modifying Marionette code directly.
@App.module "Views", (Views, App, Backbone, Marionette, $, _) ->

  class Views.ItemView extends Marionette.ItemView

    # https://github.com/gmac/backbone.epoxy/issues/94
    constructor: ->
      Marionette.ItemView.prototype.constructor.apply(@, arguments)
      @epoxify()

    epoxify: ->
      _.defaults @, Backbone.Epoxy.View::
      @listenTo @, "ui:bind", @applyBindings
      @listenTo @, "before:close", @removeBindings

    bindUIElements: ->
      @trigger "ui:bind"
      Marionette.View::bindUIElements.apply this, arguments