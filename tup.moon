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
for file in enum_dir 'mmm'
  continue if file\match '%.server%.moon$'
  basename = assert file\match '(.*)%.moon$'
  basename = (file\match '(.*)%.client') or basename
  print ": #{file} |> ^ MOON %b > %o^ moonc -o %o %f |> dist/#{basename}.lua {mmm_src}"

-- GENERATE BUNDLES
print ": {mmm_src} |> ^ BUNDLE mmm^ moon bundle.moon %o %f |> dist/mmm.bundle.lua"

-- COMPILE AND DUMP TREE
print ": |> ^ DUMP root^ moon dump_tree.moon %o |> dist/root.lua"

-- PRE-RENDER TREE
import load_fileder from require 'mmm.mmmfs.fs'

root = load_fileder!
root\mount!

for fileder in coroutine.wrap root\iterate
  name = fileder\gett 'name: alpha'
  { :path, :source_module } = fileder

  path = '/' if path == ''

  print ": |> ^ HTML #{path}^ moon render.moon %o '#{path}' |> dist#{path}/index.html"
