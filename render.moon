package.moonpath = './?.server.moon;./?/init.server.moon;' .. package.moonpath
require 'mmm.init'
import render from require 'mmm.mmmfs'
import load_fileder from require 'mmm.mmmfs.fs'

-- usage:
-- moon render.moon <path_to_root>
{ root } = arg

assert root, "please specify the relative root path as an argument"

require 'lfs'
cwd = lfs.currentdir!
path = ''

while root\find '^%.%./'
  root = root\match '^%.%./(.*)'
  cwd, trimmed = cwd\match '(.*)(/[^/]+)$'
  path = trimmed .. path

root = dofile '$bundle.lua'
root\mount path, true

content, rehydrate = render root, path
assert content, "no content"

with io.open 'index.html', 'w'
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
    <script type=\"application/lua\">require 'mmm'</script>

    #{rehydrate}
  </body>
</html>"
  \close!
