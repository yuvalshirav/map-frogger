@App.module "GameModule", (GameModule, App, Backbone, Marionette, $, _) ->

  class GameModule.Router extends Marionette.AppRouter
    appRoutes:
      "game": "welcome"

  API =

    welcome: ->
      new GameModule.Map.Controller()

  App.addInitializer ->
    new GameModule.Router
      controller: API

