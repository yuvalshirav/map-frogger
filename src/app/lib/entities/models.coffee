# Model
#
# Extends from `Backbone.Model`. Is used as a wrapper in order
# to be able to add custom code to all `Model` on the application
# without modifying Marionette code directly.
@App.module "Entities", (Entities, App, Backbone, Marionette, $, _) ->

  class Entities.Model extends Backbone.Model
