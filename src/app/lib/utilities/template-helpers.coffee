# Template Helpers Utils
#
# Register helpers for the templates.
@App.module "Utilities", (Utilities, App, Backbone, Marionette, $, _) ->

  # linkTo Helper
  #
  # Renders a link with the provided text and a URL.
  #
  # Options:
  # * `external`: If the link points to an internal route or an external URL
  Handlebars.registerHelper "linkTo", (name, url, options = {}) ->
    options = options.hash

    _.defaults options,
      external: false

    url = "#" + url unless options.external

    return new Handlebars.SafeString("<a href='#{url}'>#{name}</a>")
