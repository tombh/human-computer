m = require 'mithril'

module.exports = {
  token: m.prop(localStorage.token),

  # Trade credentials for a token
  login: (email, password) ->
    options = {
      method: 'POST'
      url: '/auth/login'
      data: { email:email, password:password }
    }
    @ajax(options).then (result) ->
      @token()
      localStorage.token = result.token
      res.token

  # Forget token
  logout: ->
    @token false
    delete localStorage.token

  # Signup on the server for new login credentials
  register: (email, password) ->
    @ajax({
      method: 'POST',
      url: '/auth/register',
      data: { email:email, password:password }
    })

  # Ensure verify token is correct
  verify: (token) ->
    @ajax({
      method: 'POST',
      url: '/auth/verify',
      data: { token: token }
    })

  # Get current user object
  user: ->
    @request '/auth/user'

  success: (result) ->
    console.log "AJAX success", result
    result

  error: (result) ->
    # If auth error, redirect
    if result.status == 401
      # @originalRoute = m.route()
      m.route '/login'
    console.log "AJAX error", result.message.error
    result

  # Central wrapper around Mithril's request method
  ajax: (options) ->
    # Handle non-JSON responses, such as when the server is not reached
    options.extract = (xhr) ->
      # Fragile but fast
      isJson = '"[{'.indexOf(xhr.responseText.charAt(0)) != -1
      if isJson then xhr.responseText else JSON.stringify xhr.responseText
    options.unwrapError = (res) ->
      error_in_result = (typeof res is 'object') and ('error' in res)
      message = if error_in_result then res.error else res
      { message: message }

    m.request(options).then(@success, @error)

  # Make an authenticated request
  request: (options) ->
    if typeof options is 'string'
      options = { method: 'GET', url: options }
    oldConfig = options.config || ->
    options.config = (xhr) =>
      xhr.setRequestHeader "Authorization", "Bearer " + @token()
      oldConfig xhr

    @ajax options
}
