package.moonpath = './?.server.moon;' .. package.moonpath
require 'lfs'
require 'lib.init'

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

for file in enum_dir 'app'
  basename = assert file\match '(.*)%.moon$'
  print ": #{file} |> ^ MOON %b > %o^ moonc -o %o %f |> dist/#{basename}.lua"

for file in enum_dir 'lib'
  continue if file\match '%.server%.moon$'
  basename = assert file\match '(.*)%.moon$'
  basename = (file\match '(.*)%.client') or basename
  print ": #{file} |> ^ MOON %b > %o^ moonc -o %o %f |> dist/#{basename}.lua"

-- add rules for statically rendered routes
import routes from require 'app'

for { :name, :dest } in *routes
  print ": |> ^ HTML #{name}^ moon render.moon #{name} %o |> dist/#{dest}"
