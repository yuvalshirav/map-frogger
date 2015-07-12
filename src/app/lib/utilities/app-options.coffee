# # App Options Utils
#
# Utils related to the options of the application.
@App.module "Utilities", (Utilities, App, Backbone, Marionette, $, _) ->

  # After the application has been initialized, a reference to
  # the options is stored under `App.options`.
  App.on "before:start", (options = {}) ->
    _.defaults options,
      environment: "production"

    App.options = options

  # Request to get application options by name
  App.reqres.setHandler "app:option", (name) ->
    return App.options[name]
