# Model

class Game
  constructor: (@cookies, @response) ->

  node_id: ->
    @cookies.zappirynth_state || start.id

  visited: (node) ->
    @response.cookie('zappirynth_state', node.id, {expires: new Date(Date.now() + 3600*24*1000*360), path: "/"})


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
  html ->
    head -> title @node.title
  body ->
    div id: "header", ->
      h2 -> a href: "/", -> "Zappirynth"
    div id: "content", -> @content

view node: ->
  h1 @node.title
  if @node.finish()
    p "YOU'RE WINNER !"
    p -> a href: "/", -> "Start again"
  else
    ul ->
      for exit in @node.exits
        li -> a href: "/nodes/" + exit.node.id, -> exit.text

get "/", ->
  game = new Game(cookies, response)
  id = game.node_id()
  redirect "/nodes/#{id}"

get "/nodes/:id", ->
  @node = nodes.find(@id)
  game = new Game(cookies, response)
  game.visited(@node)
  render 'node'
