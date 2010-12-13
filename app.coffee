# Simple labyrinth game implemented as web application running at http://localhost:4567/
#
# Starting on a home page it presents user with a short description of his
# locations and available paths he can take (as links).
#
# When gamer gets to last location he is presented with a "YOU'RE WINNER !"
# congratulations text.
#

# Model

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
# View

layout ->
  html ->
    head -> title @node.title
  body -> @content

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
  @node = start
  render 'node'

get "/nodes/:id", ->
  @node = nodes.find(@id)
  render 'node'
