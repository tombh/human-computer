HomeController = require 'controllers/home'

describe 'Home page', ->
  it 'should render the homepage', ->
    controller = new HomeController
    SpecHelpers.ajaxResponse { message: 'boss' }
    expect(controller.bytes().message).toBe 'boss'
