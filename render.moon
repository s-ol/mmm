package.moonpath = './?.server.moon;./?/init.server.moon;' .. package.moonpath
require 'mmm.init'
import render from require 'mmm.mmmfs'
import load_fileder from require 'mmm.mmmfs.fs'

-- usage:
-- moon render.moon <output> <fileder_path>
{ output_name, path } = arg

assert output_name, "please specify the output filename as an argument"
assert path, "please specify the path name to build as an argument"

root = load_fileder 'root' .. path
root\mount path

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

    #{'' or rehydrate}
  </body>
</html>"
  \close!
