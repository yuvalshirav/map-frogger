# # CollectionView
#
# Extends from `Marionette.CollectionView`. Is used as a wrapper
# in order to be able to add custom code to all `CollectionViews`
# on the application without modifying Marionette code directly.
@App.module "Views", (Views, App, Backbone, Marionette, $, _) ->

  class Views.CollectionView extends Marionette.CollectionView
