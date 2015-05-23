m = require 'mithril'
layout = require 'views/layout/layout'

Logger = require 'models/logger'

Logger.level = Logger.DEBUG if document.location.hostname == "localhost"

withLayout = (Controller, view) ->
  controller: Controller
  view: layout(view)

m.route.mode = 'pathname'
m.route(document.body, "/", {
  "/": withLayout( require('controllers/home'), require('views/home') ),
  "/login": require('./pages/Login.js'),
  "/logout": require('./pages/Logout.js'),
  "/register": require('./pages/Register.js'),
  "/verify/:code": require('./pages/Verify.js'),
  "/tasty": require('./pages/Tasty.js')
})
