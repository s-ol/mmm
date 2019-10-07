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
import render from require 'mmm.mmmfs.layout'
import SQLStore from require 'mmm.mmmfs.drivers.sql'
import load_tree from require 'build.util'

-- usage:
-- moon render_all.moon [db.sqlite3] [startpath]
{ file, startpath } = arg

export BROWSER

tree = load_tree SQLStore :name
tree = tree\walk startpath if startpath

for fileder in coroutine.wrap tree\iterate
  print "rendering '#{fileder.path}'..."
  os.execute "mkdir -p 'out/#{fileder.path}'"

  BROWSER = Browser fileder
  with io.open "out/#{fileder.path}/index.html", 'w'
    \write render (tohtml BROWSER), fileder
    \close!
