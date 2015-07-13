#= require "../vendor/jquery/dist/jquery.js"
#= require "../vendor/underscore/underscore.js"
#= require "../vendor/underscore-strings/src/underscore.strings.js"
#= require "../vendor/backbone/backbone.js"
#= require "../vendor/backbone.epoxy/backbone.epoxy.js"
#= require "../vendor/marionette/lib/backbone.marionette.js"
#= require "../vendor/handlebars/handlebars.js"
#= require "../vendor/rsvp/rsvp.js"
#= require "../vendor/jquery-touchswipe/jquery.touchSwipe.js"
#= require "./app/lib/pathAnimator.js"
#= require "./app/lib/sat-js.js"
#= require "./app/lib/backbone.deepmodel.js"
#= require "./app/lib/jquery.visibility.js"
#= require "./app/lib/spin.js"
#= require "./app/lib/fastclick.js"

#= require_tree "config/"

#= require "app/app.coffee"

#= require_tree "app/lib/utilities/"
#= require_tree "app/lib/entities/"
#= require_tree "app/lib/controllers/"
#= require_tree "app/lib/views/"
#= require_tree "app/lib/components/"

#= require_tree "app/entities/"

#= require_tree "app/modules/"
