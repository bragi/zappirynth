class Game
  constructor: (@cookies, @response) ->
    @version = 3
    @cookieName = "zappirynthstate#{@version}"
    cookie = @cookies[@cookieName]
    @fromString(cookie || '{"inProgress": false, "nodeId": 1}')

  cookieExpires: ->
    new Date(Date.now() + 3600*24*1000*360)

  visited: (node) ->
    @nodeId = node.id
    @save()

  reset: ->
    console.log "Resetting game"
    @response.clearCookie(@cookieName)

  start: (@name) ->
    console.log "Starting new game"
    this.inProgress = true
    @save()

  save: ->
    console.log "Saving game state:#{@toString()}"
    @response.cookie(@cookieName, @toString(), {expires: @cookieExpires(), path: "/"})

  fromString: (text) ->
    state = JSON.parse(text)
    @name = state.name
    @nodeId = state.nodeId || start.id
    @inProgress = state.inProgress

  toJSON: ->
    {name: @name, nodeId: @nodeId, inProgress: @inProgress}

  toString: ->
    JSON.stringify(this)

def Game: Game
