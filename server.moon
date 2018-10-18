package.moonpath = './?.server.moon;' .. package.moonpath

export MODE, warn, append
MODE = 'SERVER'
warn = (...) ->
  io.stderr\write table.concat { ... }, '\t'
  io.stderr\write '\n'

-- shorthand to append elements to body
buffer = ''
append = (val) ->
  buffer ..= val
flush = ->
  with x = buffer
    buffer = ''

import insert_loader from require 'duct_tape'
insert_loader!

error "please specify the module to build as an argumnet" unless arg[1]

require "app.#{arg[1]}"

print "<!DOCTYPE html>
<html>
  <head>
    <script src=\"fengari-web.js\"></script>
    <title>MMM: lunar low-gravity scripting playground</title>
  </head>
  <body>
    #{flush!}
  </body>
</html>"
