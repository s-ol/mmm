package.moonpath = './?.shared.moon;./?.server.moon;' .. package.moonpath
import flush from require 'lib.init'

import routes from require 'app'

route_name = assert arg[1], "please specify the route name to build as an argument"
route = assert routes[route_name], "route not found: '#{route_name}'"
route\render!

print "<!DOCTYPE html>
<html>
  <head>
    <meta charset=\"UTF-8\">
    <title>MMM: lunar low-gravity scripting playground</title>
    <link rel=\"stylesheet\" type=\"text/css\" href=\"/main.css\" />
  </head>
  <body>
    <script src=\"/fengari-web.js\"></script>
    <script type=\"application/lua\" src=\"/lib/init.client.moon.lua\"></script>
    #{flush!}
  </body>
</html>"
