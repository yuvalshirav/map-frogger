# # Layout
#
# Extends from `Marionette.LayoutView`. Is used as a wrapper
# in order to be able to add custom code to all `Layout`
# on the application without modifying Marionette code directly.
@App.module "Views", (Views, App, Backbone, Marionette, $, _) ->

  class Views.Layout extends Marionette.LayoutView
