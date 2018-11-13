require 'mmm'
import Fileder, Key from require 'mmm.mmmfs.fileder'
import opairs from require 'mmm.ordered'
import to_lua from require 'moonscript.base'
require 'lfs'

-- usage:
-- moon bundle_fileder.moon <dirname> <facets>... -- <children>...
{ dirname } = arg

assert dirname, "please specify the fileder dirname"

facets = {}
children_bundles = {}

do
  addto = facets
  for file in *arg[2,]
    continue if file == 'Tupdefault.lua'

    if file == '--'
      addto = children_bundles
      continue
    table.insert addto, file

-- compile a moonscript facet to lua
compile = (old, new, val) -> "-- this facet has been transpiled from '#{old}'
-- to '#{new}' for execution in the browser.
-- refer to the original facet as the source.
#{to_lua val}"

-- load a fs file as a fileder facet
load_facet = (filename) ->
  key = (filename\match '(.*)%.%w+') or filename
  key = Key key\gsub '%$', '/'

  file = io.open filename, 'r'
  value = file\read '*all'
  file\close!

  key, value

-- escape a string for lua aparser
escape = (str) -> string.format '%q', tostring str

-- compile a moonscript facet to lua
compile = (old, new, val) -> "-- this facet has been transpiled from '#{old}'
-- to '#{new}' for execution in the browser.
-- refer to the original facet as the source.
#{to_lua val}"

-- dump a fileder subtree as Lua source
dump_fileder = do
  _dump = (fileder, root=false) ->
    code = "Fileder {"

    for key, val in pairs fileder.facets
      if key.original
        key = "fromcache(#{escape key}, #{escape key.original})"
      else
        key = escape key
      code ..= "\n[#{key}] = #{escape val},"

    for child in *fileder.children
      code ..= "\n#{_dump child},"

    code ..= "\n}"
    code


  (fileder) -> "
local mmmfs = require 'mmm.mmmfs'
local Key, Fileder = mmmfs.Key, mmmfs.Fileder
local function fromcache(str, orig)
  local key = Key(str)
  key.original = Key(orig)
  return key
end

return #{_dump fileder, true}
  "

with io.open '$bundle.lua', 'w'
  \write dump_fileder with Fileder 'name: alpha': dirname
    order = nil
    children = {}

    for facet in *facets
      if facet == '$order'
        order = [line for line in io.lines facet]
        continue
      key, value = load_facet facet
      .facets[key] = value

    for key, value in pairs .facets
      continue unless key.type\match '^text/moonscript %->'
      built_key = Key key.name, key.type\gsub '^text/moonscript %-> (.*)', 'text/lua -> %1'
      built_key.original = key

      continue if \has built_key
      .facets[built_key] = compile key, built_key, value

    for child in *children_bundles
      -- @BUG: child bundles are malformed due to Tup bug ($ symbol)
      child = child\gsub '/%.lua$', '/$bundle.lua'

      dirname = assert child\match '^([%w-_%.]+)/%$bundle%.lua$'
      children[dirname] = dofile child

    if order
      -- order from order file
      for i, name in pairs order
        child = assert children[name], "child in $order but not fs: #{name} of #{path}"
        table.insert .children, child
        children[name] = nil

    -- sort remainder alphabeticalally
    for name, child in opairs children
      table.insert .children, child
      warn "child #{name} of #{path} not in $order!" if order

  \close!
