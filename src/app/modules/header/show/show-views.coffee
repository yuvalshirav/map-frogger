# # Show Views
#
# Defines all views used on the "show" action of the
# `Header` module.
@App.module "HeaderModule.Show", (Show, App, Backbone, Marionette, $, _) ->

  # ## HeaderView
  #
  # Renders the header section of the app. It extends
  # from App's base ItemView (which extends Marionette.ItemView)
  class Show.HeaderView extends App.Views.ItemView
    template: "header/show/header"
