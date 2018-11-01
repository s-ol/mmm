package.moonpath = './?.server.moon;./?/init.server.moon;' .. package.moonpath
require 'lfs'
require 'mmm.init'

-- enumerate moonscript source files
enum_dir = do
  yieldtree = (dir) ->
    for entry in lfs.dir dir
      if entry != '.' and entry != '..' then
        entry = dir .. "/" .. entry
        attr = lfs.attributes entry
        switch attr.mode
          when 'file' then coroutine.yield entry, attr
          when 'directory' yieldtree entry

  (dir) ->
    assert dir and dir ~= '', "directory parameter is missing or empty"
    dir = dir\sub 1, -2 if '/' == dir\sub -1

    coroutine.wrap -> yieldtree dir

-- COMPILE MOONSCRIPT
-- mmmfs tree
for file in enum_dir 'root'
  basename = assert file\match '(.*)%.moon$'
  print ": #{file} |> ^ MOON %b > %o^ moonc -o %o %f |> dist/#{basename}.lua"

-- mmm
for file in enum_dir 'mmm'
  continue if file\match '%.server%.moon$'
  basename = assert file\match '(.*)%.moon$'
  basename = (file\match '(.*)%.client') or basename
  print ": #{file} |> ^ MOON %b > %o^ moonc -o %o %f |> dist/#{basename}.lua"

-- PRE-RENDER MMMFS
import module_roots from require 'mmm.mmmfs'

root = require 'root'
root\mount!

module_roots = {}
for fileder in coroutine.wrap root\iterate
  name = fileder\gett 'name: alpha'
  { :path, :source_module } = fileder

  module_roots[source_module] or= fileder.path
  prefix_path = module_roots[source_module]

  path = '/' if path == ''

  if prefix_path
    print ": |> ^ HTML #{name}^ moon render.moon %o '#{path}' #{source_module} '#{prefix_path}' |> dist#{path}/index.html"
  else
    print ": |> ^ HTML #{name}^ moon render.moon %o '#{path}' |> dist#{path}/index.html"
