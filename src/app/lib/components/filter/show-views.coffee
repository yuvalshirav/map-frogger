# Show Views
#
# This are the views used for the "show" action of the `Filter` component.
@App.module "Components.Filter", (Filter, App, Backbone, Marionette, $, _) ->

  timer = null

  class Filter.FilterView extends App.Views.ItemView
    className: "filter-component"
    template: "filter/filter"
    ui:
      textfield: "input[type='text']"
    events:

      # On each keypress of the text field of the component
      # a `filter:text:changed` event is triggered on the view,
      # checking against a timeout to avoid sending too many
      # events.
      "keyup @ui.textfield": (e) ->
        e.preventDefault()

        clearTimeout timer

        timer = setTimeout =>
          @trigger "filter:text:changed", @ui.textfield.val()
        , @options.delay || 0

    # Custom `serializeData()` method for the view in order to pass
    # `options` variable to the template
    serializeData: ->
      return @options
