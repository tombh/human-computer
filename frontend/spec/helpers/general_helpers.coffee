# Turn the logger off in test envs
Logger = require 'models/logger'
Logger.level = Logger.OFF

# Collection of general helpers
class SpecHelpers
  # Return a fake AJAX response. Must be called *after* any m.request calls
  @ajaxResponse = (response) ->
    xhr = mock.XMLHttpRequest.$instances.pop()
    xhr.responseText = JSON.stringify response
    xhr.onreadystatechange()

module.exports = {
  localStorage: {},
  SpecHelpers: SpecHelpers
}
