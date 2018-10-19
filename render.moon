package.moonpath = './?.shared.moon;./?.server.moon;' .. package.moonpath

import to_lua from require 'moonscript.base'
import flush from require 'lib.init'

error "please specify the module to build as an argumnet" unless arg[1]

require "app.#{arg[1]}"

load_file = (name) ->
  file = io.open name
  with file\read '*a'
    file\close!

print "<!DOCTYPE html>
<html>
  <head>
    <meta charset=\"UTF-8\">
    <title>MMM: lunar low-gravity scripting playground</title>
  </head>
  <body>
    <script src=\"fengari-web.js\"></script>
    <script src=\"lib/init.client.lua\"></script>
    #{flush!}
  </body>
</html>"
