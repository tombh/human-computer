m = require 'mithril'
Navbar = require 'components/Navbar'

module.exports = (content) ->
  (controller) ->
    m '.container', [
      m.component { controller: Navbar.controller, view: Navbar.view }
      m 'p', controller.api.message(),
      content(controller)
    ]
