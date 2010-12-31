vows = require 'vows'
zombie = require 'zombie'
assert = require 'assert'

# Starting a game
browser = new zombie.Browser

browser.visit "http://localhost:5678/", (err, browser) ->
  browser.fill "name", "Bragi"
  browser.pressButton "Start game", (err, browser) ->
    assert.equal browser.text("#content h2"), "Welcome Bragi"