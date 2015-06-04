m = require 'mithril'

module.exports = (content) ->
  (controller) ->
    m '.container', [
      m 'p', controller.api.message()
      content(controller)
    ]
