m = require 'mithril'

module.exports = (content) ->
  (controller) ->
    m '.container', [
      m 'p.message', controller.api.message()
      content(controller)
    ]
