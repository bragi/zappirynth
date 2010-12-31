fs            = require("fs")
path          = require("path")
{spawn, exec} = require("child_process")
stdout        = process.stdout

# ANSI Terminal Colors.
bold  = "\033[0;1m"
red   = "\033[0;31m"
green = "\033[0;32m"
reset = "\033[0m"

# Log a message with a color.
log = (message, color, explanation) ->
  console.log color + message + reset + ' ' + (explanation or '')

# Handle error, do nothing if null
onerror = (err)->
  if err
    process.stdout.write "#{red}#{err.stack}#{reset}\n"
    process.stdout.on "drain", -> process.exit -1

## Testing ##

runTests = (callback)->
  log "Running test suite ...", green
  exec "vows --spec", (err, stdout)->
    process.stdout.write stdout
    callback err
task "test", "Run all tests", -> runTests onerror
