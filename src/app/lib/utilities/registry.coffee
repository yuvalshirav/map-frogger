# Registry Utilities
#
# Utils related with the registry and log of object instances. It is intented
# to be used for debugging purposes.
@App.module "Utilities", (Utilities, App, Backbone, Marionette, $, _) ->

  API =

    # Stores an instance in the registry
    register: (instance, id) ->
      App._registry ?= {}
      App._registry[id] = instance

    # Removes an instance of the registry
    unregister: (instance, id) ->
      delete App._registry[id]

    # Empty the registry, showing how many instances were on the registry, and
    # how many are left
    resetRegistry: ->
      oldCount = @getRegistrySize()

      @closeRegions()

      ret =
        count: @getRegistrySize()
        previous: oldCount
        msg: "There were #{oldCount} controllers in the registry, there are now #{@getRegistrySize()}"

      console.info ret.msg if App.request("app:option", "environment") is "dev"

      return ret

    # Close all the regions on the controller instances of the registry
    closeRegions: ->
      for key, controller of App._registry
        controller?.region?.destroy()

    # Get the size of the registry
    getRegistrySize: ->
      _.size(App._registry)

  # Creates a command for registering instances on the registry
  App.commands.setHandler "register:instance", (instance, id) ->
    API.register instance, id if App.request("app:option", "environment") is "dev"

  # Creates a command for removing instances from the registry
  App.commands.setHandler "unregister:instance", (instance, id) ->
    API.unregister instance, id if App.request("app:option", "environment") is "dev"

  # Creates a command for resetting the registry
  App.reqres.setHandler "reset:registry", ->
    API.resetRegistry()
