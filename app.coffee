# Model
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

class Exit
  constructor: (@text, @node) ->

class Node
  constructor: (@id, @title, @text) ->
    @exits = []
  addExit: (text, node) ->
    @exits.push(new Exit(text, node))
  finish: ->
    @exits.length == 0

class Nodes
  constructor: ->
    @next_id = 1
    @nodes = []
  make: (title, text) ->
    node = new Node(@next_id++, title, text)
    @nodes[node.id] = node
    node
  find: (id) ->
    @nodes[id]

nodes = new Nodes

start = nodes.make "Welcome traveler", "Welcome to labyrinth. Select your path"
left =  nodes.make "Left path", "You are on a left path"
right =  nodes.make "Right path", "You are on a right path"
finish = nodes.make "Finish", "You have reached the destination"

start.addExit("Go left", left)
start.addExit("Go right", right)

left.addExit("Go straight", finish)
left.addExit("Go right", right)

right.addExit("Go straight", finish)
right.addExit("Go left", left)

def nodes: nodes
def start: start
def Game: Game

# View
layout ->
  doctype
  html ->
    head -> title @title
  body ->
    div id: "header", ->
      h2 -> "Zappirynth"
      p ->
        form action: "/restart", method: "post", ->
          input type: "submit", value: "Restart"
    div id: "content", -> @content

view node: ->
  @title = @node.title
  h1 @node.title
  h2 "Welcome #{@game.name}"
  if @node.finish()
    p "YOU'RE WINNER !"
    p ->
      form action: "/restart", method: "post", ->
        input type: "submit", value: "Restart"
  else
    ul ->
      for exit in @node.exits
        li -> a href: "/nodes/" + exit.node.id, -> exit.text

view player: ->
  @title = "Name your player"
  h1 @title
  form action: "/player", method: "post", ->
    label for: "name", -> "Name"
    input type: "text", name: "name", id: "name"
    input type: "submit", value: "Start game"

view blank: ->
  @title = "Blank"
  p "Blank"

helper logHeaders: (request) ->
  console.log "Headers:"
  for header, value of request.headers
    console.log "#{header}: #{value}"
  console.log "Cookies:"
  for header, value of request.cookies
    console.log "#{header}: #{value}"

get "/", ->
  console.log "GET /"
  game = new Game(cookies, response)
  if game.inProgress
    redirect "/nodes/#{game.nodeId}"
  else
    redirect "/player"

post "/restart", ->
  console.log "POST /restart"
  game = new Game(cookies, response)
  game.reset()
  redirect "/"

get "/player", ->
  console.log "GET /player"
  render 'player'

post "/player", ->
  console.log "POST /player"
  game = new Game(cookies, response)
  game.start(params.name)
  logHeaders response
  redirect "/nodes/#{start.id}"

get "/nodes/:id", ->
  console.log "GET /nodes/#{@id}"
  logHeaders request
  @node = nodes.find(@id)
  @game = new Game(cookies, response)
  if @game.inProgress
    @game.visited(@node)
    render 'node'
  else
    redirect "/player"
