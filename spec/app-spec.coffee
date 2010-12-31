vows = require 'vows'
zombie = require 'zombie'
assert = require 'assert'

zombie.wants = (url, context)->
  topic = context.topic
  context.topic = ->
    new zombie.Browser().wants url, (err, browser)=>
      if topic
        try
          value = topic.call this, browser
          @callback null, value if value
        catch err
          @callback err
      else
        browser.wait @callback
    return
  return context

zombie.Browser.prototype.wants = (url, options, callback)->
  @visit url, options, (err, browser)=>
    callback err, this if callback

vows.describe("Application").addBatch(
  "starting game":
    zombie.wants "http://localhost:5678/"
      "should welcome user": (browser)->
        browser.fill "name", "Bragi"
        browser.pressButton "Start game", (err, browser)->
          assert.equal browser.text("#content h2"), "Welcome Bragi"
).export(module)
