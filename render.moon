import to_lua from require 'moonscript.base'
import flush from require 'server'

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
    <script type=\"application/lua\">
      #{to_lua load_file 'client.moon'}
    </script>
    #{flush!}
  </body>
</html>"
