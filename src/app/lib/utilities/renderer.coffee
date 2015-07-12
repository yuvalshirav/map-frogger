# # Renderer Utils
#
# Utils related with the rendering of the Views.
@App.module "Utilities", (Utilities, App, Backbone, Marionette, $, _) ->

_.extend Marionette.Renderer,

  # Paths where the templates of the views can be found
  lookups: ["modules/", "lib/components/"]

  # Overwrite the views default `render()` method
  render: (template, data) ->

    # Don't render if the template is false
    return if template is false

    path = @getTemplate(template)

    # If the template is not found, throw an error
    unless path
      error = "Template '#{template}' not found!"
      console.error error
      throw new Error(error)
      return

    # Execute the template (It is a Handlebars template)
    path(data)

  # Search for the template on the lookups
  getTemplate: (template) ->
    for lookup in @lookups
      for path in [template, @withTemplate(template)]
        return App.templates[lookup + path] if App.templates[lookup + path]

  # Allow `getTemplate()` method to search for templates without having to
  # specify "templates/" on the path.
  withTemplate: (string) ->
    array = string.split("/")
    array.splice(-1, 0, "templates")
    array.join("/")
