add = (tmpl) ->
  package.path ..= ";#{tmpl}.lua"
  package.moonpath ..= ";#{tmpl}.moon"

add '?'
add '?.server'
add '?/init'
add '?/init.server'

require 'mmm'
import load_tree from require 'mmm.mmmfs.fileder'
import get_store from require 'mmm.mmmfs.stores'
import render from require 'mmm.mmmfs.layout'

-- usage:
-- moon render_all.moon [STORE] [startpath]
{ store, startpath } = arg

export STATIC
STATIC = true

store = get_store store
tree = load_tree store
tree = tree\walk startpath if startpath

for fileder in coroutine.wrap tree\iterate
  print "rendering '#{fileder.path}'..."
  os.execute "mkdir -p 'out/#{fileder.path}'"

  with io.open "out/#{fileder.path}/index.html", 'w'
    \write render (fileder\get 'text/html'), fileder
    \close!
