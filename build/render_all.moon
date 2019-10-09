add = (tmpl) ->
  package.path ..= ";#{tmpl}.lua"
  package.moonpath ..= ";#{tmpl}.moon"

add '?'
add '?.server'
add '?/init'
add '?/init.server'

require 'mmm'
import load_tree from require 'mmm.mmmfs.fileder'
import render from require 'mmm.mmmfs.layout'
import SQLStore from require 'mmm.mmmfs.drivers.sql'

-- usage:
-- moon render_all.moon [db.sqlite3] [startpath]
{ file, startpath } = arg

export STATIC
STATIC = true

tree = load_tree SQLStore :file
tree = tree\walk startpath if startpath

for fileder in coroutine.wrap tree\iterate
  print "rendering '#{fileder.path}'..."
  os.execute "mkdir -p 'out/#{fileder.path}'"

  with io.open "out/#{fileder.path}/index.html", 'w'
    \write render (fileder\get 'text/html'), fileder
    \close!
