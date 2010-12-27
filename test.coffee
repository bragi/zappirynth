require 'zappa'
tobi = require 'tobi'
app = require './app'

browser = tobi.createBrowser app

browser.get "/", (request, response) ->
  response.should.have.status(301)