require 'mmm'
import get_path from require 'build.util'
import tohtml from require 'mmm.component'
import Browser from require 'mmm.mmmfs.browser'

export BROWSER

-- usage:
-- moon render.moon <path_to_root>
{ path_to_root } = arg

seed = (str) ->
  len = #str
  rnd = -> math.ceil math.random! * len

  math.randomseed len

  return if len == 0

  upper, lower = 0, 0
  for i=1,4
    upper += str\byte rnd!
    upper *= 0x100

    lower += str\byte rnd!
    lower *= 0x100

  math.randomseed upper, lower

pick = (...) ->
  num = select '#', ...
  i = math.ceil math.random! * num
  select i, ...

assert path_to_root, "please specify the relative root path"
path = get_path path_to_root

seed path

root = dofile '$bundle.lua'
assert root, "couldn't load $bundle.lua"
root\mount path, true

BROWSER = Browser root, path

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

    <link href=\"https://fonts.googleapis.com/css?family=Source+Sans+Pro:200,400\" rel=\"stylesheet\">
  </head>
  <body>
    <header>
      <h1>
        <i class=\"sun\">☉</i>
        <b></b>
        <span class=\"bold\">mmm</span>
        .s-ol.nu
      </h1>
      <span>
        fun stuff with code and wires
<!--
        #{pick 'fun', 'cool', 'weird', 'interesting', 'new'}
        #{pick 'stuff', 'things', 'projects', 'experiments', 'news'}
        with
        #{pick 'mostly code', 'code and wires', 'silicon', 'electronics'}
-->
      </span>
    </header>

    #{assert (tohtml BROWSER), "couldn't render BROWSER"}

    <script src=\"/highlight.pack.js\"></script>
    <script src=\"//cdnjs.cloudflare.com/ajax/libs/marked/0.5.1/marked.min.js\"></script>
    <script src=\"//cdnjs.cloudflare.com/ajax/libs/svg.js/2.6.6/svg.min.js\"></script>
    <script src=\"/fengari-web.js\"></script>
    <script type=\"application/lua\" src=\"/mmm.bundle.lua\"></script>
    <script type=\"application/lua\">require 'mmm'</script>

    <script type=\"application/lua\">
      on_load = on_load or {}
      table.insert(on_load, function()
        local path = #{string.format '%q', path}
        local browser = require 'mmm.mmmfs.browser'
        local root = dofile '/$bundle.lua'
        root:mount('', true)

        BROWSER = browser.Browser(root, path, true)
      end)
    </script>
  </body>
</html>"
  \close!
