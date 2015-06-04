m = require 'mithril'
layout = require 'views/layout/layout'

Logger = require 'models/logger'

global.env = 'DEV' if document.location.hostname == "localhost"

Logger.level = Logger.DEBUG if global.env == 'DEV'

# Preload all controllers and views
controllers = require 'controllers/*.coffee', {mode: 'hash'}
views = require 'views/*.coffee', {mode: 'hash'}

# Wrap a view in the layout view
withLayout = (Controller, view) ->
  controller: Controller
  view: layout(view)

route = (name) ->
  withLayout( controllers[name], views[name] )

m.route.mode = 'pathname'
m.route(document.body, "/", {
  "/": route('home'),
  "/pid/:pid": route('process')
})
