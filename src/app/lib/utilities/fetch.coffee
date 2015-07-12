# # Fetch Utils
#
# Utilities related to the fetching of entities.
@App.module "Utilities", (Utilities, App, Backbone, Marionette, $, _) ->

  # Creates a `when:fetched` command, recieving some entities
  # and a callback to be executed when those entities are fetched
  App.commands.setHandler "when:fetched", (entities, callback) ->

    # Get all the xhrs of the entities being fetched
    xhrs = _.chain([entities]).flatten().pluck("_fetch").value()

    # When all the xhrs are completed, executes the callback
    $.when(xhrs...).done ->
      callback()
