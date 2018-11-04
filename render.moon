package.moonpath = './?.server.moon;./?/init.server.moon;' .. package.moonpath
import flush from require 'mmm.init'
import render from require 'mmm.mmmfs'

-- usage:
-- moon render.moon <output> <fileder_path> [<prefix module> <prefix path>]
{ output_name, path, prefix_mod, prefix_path } = arg

assert output_name, "please specify the output filename as an argument"
assert path, "please specify the path name to build as an argument"

root = if prefix_mod and prefix_path
  -- prefix module and path are given, skip deeper into the tree
  assert path\match '^' .. prefix_path
  with require prefix_mod
    \mount prefix_path, true
else
  -- load full tree
  with require 'root'
    \mount!

content, rehydrate = render root, path
assert content, "no content"

with io.open output_name, 'w'
  \write "<!DOCTYPE html>
<html>
  <head>
    <meta charset=\"UTF-8\">
    <title>MMM: lunar low-gravity scripting playground</title>
    <link rel=\"stylesheet\" type=\"text/css\" href=\"/main.css\" />
    <!--
    <link rel=\"preload\" as=\"fetch\" href=\"/mmm/dom/init.lua\" />
    <link rel=\"preload\" as=\"fetch\" href=\"/mmm/component/init.lua\" />
    <link rel=\"preload\" as=\"fetch\" href=\"/mmm/mmmfs/init.lua\" />
    <link rel=\"preload\" as=\"fetch\" href=\"/mmm/mmmfs/fileder.lua\" />
    <link rel=\"preload\" as=\"fetch\" href=\"/mmm/mmmfs/browser.lua\" />
    -->
  </head>
  <body>
    #{content}

    <script src=\"/highlight.pack.js\"></script>
    <script src=\"//cdnjs.cloudflare.com/ajax/libs/marked/0.5.1/marked.min.js\"></script>
    <script src=\"//cdnjs.cloudflare.com/ajax/libs/svg.js/2.6.6/svg.min.js\"></script>
    <script src=\"/fengari-web.js\"></script>
    <script type=\"application/lua\" src=\"/mmm.bundle.lua\"></script>
    <script type=\"application/lua\" src=\"/root.bundle.lua\"></script>
    <script defer type=\"application/lua\" src=\"/mmm/init.lua\"></script>

    #{rehydrate}
  </body>
</html>"
  \close!
