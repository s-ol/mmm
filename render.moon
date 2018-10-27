package.moonpath = './?.shared.moon;./?.server.moon;' .. package.moonpath
import flush from require 'lib.init'

import indexed from require 'app'

route_name = assert arg[1], "please specify the route name to build as an argument"
output_name = assert arg[2], "please specify the output filename as an argument"
route = assert indexed[route_name], "route not found: '#{route_name}'"
route\render!

with io.open output_name, 'w'
  \write "<!DOCTYPE html>
<html>
  <head>
    <meta charset=\"UTF-8\">
    <title>MMM: lunar low-gravity scripting playground</title>
    <link rel=\"stylesheet\" type=\"text/css\" href=\"/main.css\" />
  </head>
  <body>
    <script src=\"/fengari-web.js\"></script>
    <script src=\"//cdn.jsdelivr.net/npm/marked/marked.min.js\"></script>
    <script type=\"application/lua\" src=\"/lib/init.client.moon.lua\"></script>

    #{flush!}
  </body>
</html>"
  \close!
