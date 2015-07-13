# # CompositeView
#
# Extends from `Marionette.CompositeView`. Is used as a wrapper
# in order to be able to add custom code to all `CompositeView`
# on the application without modifying Marionette code directly.
@App.module "Views", (Views, App, Backbone, Marionette, $, _) ->

  class Views.CompositeView extends Marionette.CompositeView

    # https://github.com/gmac/backbone.epoxy/issues/94
    constructor: ->
      Marionette.CompositeView.prototype.constructor.apply(@, arguments)
      @epoxify()

    epoxify: ->
      _.defaults @, Backbone.Epoxy.View::
      @listenTo @, "ui:bind", @applyBindings
      @listenTo @, "before:close", @removeBindings

    bindUIElements: ->
      @trigger "ui:bind"
      Marionette.View::bindUIElements.apply this, arguments
