add = (tmpl) ->
  package.path ..= ";#{tmpl}.lua"
  package.moonpath ..= ";#{tmpl}.moon"

add '?'
add '?.server'
add '?/init'
add '?/init.server'

require 'mmm'
import tohtml from require 'mmm.component'
import Browser from require 'mmm.mmmfs.browser'
import get_meta, header, footer from require 'build.layout'

export BROWSER

render = (fileder, output) ->
  BROWSER = Browser fileder

  with io.open output, 'w'
    \write [[
  <!DOCTYPE html>
  <html>
    <head>
      <link rel="stylesheet" type="text/css" href="/main.css" />
      <!--
      <link rel="preload" as="fetch" href="/mmm/dom/init.lua" />
      <link rel="preload" as="fetch" href="/mmm/component/init.lua" />
      <link rel="preload" as="fetch" href="/mmm/mmmfs/init.lua" />
      <link rel="preload" as="fetch" href="/mmm/mmmfs/fileder.lua" />
      <link rel="preload" as="fetch" href="/mmm/mmmfs/browser.lua" />
      -->

      <link href="https://fonts.googleapis.com/css?family=Source+Sans+Pro:200,400" rel="stylesheet">
    ]]
    \write "
      #{get_meta fileder}
    </head>
    <body>
      #{header}

      #{assert (tohtml BROWSER), "couldn't render BROWSER"}

      #{footer}
    "
    \write [[
      <script src="/highlight.pack.js"></script>
      <script src="//cdnjs.cloudflare.com/ajax/libs/marked/0.5.1/marked.min.js"></script>
      <script src="//cdnjs.cloudflare.com/ajax/libs/svg.js/2.6.6/svg.min.js"></script>
      <script src="//platform.twitter.com/widgets.js" charset="utf-8"></script>
      <script src="/fengari-web.js"></script>
      <script type="application/lua" src="/mmm.bundle.lua"></script>
      <script type="application/lua">require 'mmm'</script>
    ]]
    \write "
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
  </html>
    "
    \close!

import SQLStore from require 'mmm.mmmfs.drivers.sql'
import Fileder, Key from require 'mmm.mmmfs.fileder'

-- split filename into dirname + basename
dir_base = (path) ->
  dir, base = path\match '(.-)([^/]-)$'
  if dir and #dir > 0
    dir = dir\sub 1, #dir - 1

  dir, base

load_tree = (store, root='') ->
  fileders = setmetatable {},
    __index: (path) =>
      with val = Fileder {}
        .path = path
        rawset @, path, val

  root = fileders[root]
  root.facets['name: alpha'] = ''
  for fn, ft in store\list_facets root.path
    val = store\load_facet root.path, fn, ft
    root.facets[Key fn, ft] = val

  for path in store\list_all_fileders root.path
    fileder = fileders[path]

    parent, name = dir_base path
    fileder.facets['name: alpha'] = name
    table.insert fileders[parent].children, fileder

    for fn, ft in store\list_facets path
      val = store\load_facet path, fn, ft
      fileder.facets[Key fn, ft] = val

  root

tree = load_tree SQLStore!

for fileder in coroutine.wrap tree\iterate
  print "rendering '#{fileder.path}'..."
  os.execute "mkdir -p 'out/#{fileder.path}'"
  render fileder, "out/#{fileder.path}/index.html"
