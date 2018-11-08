package.moonpath = './?.server.moon;./?/init.server.moon;' .. package.moonpath
require 'mmm.init'
import Key from require 'mmm.mmmfs'
import load_fileder, load_property from require 'mmm.mmmfs.fs'
import to_lua from require 'moonscript.base'

-- usage:
-- moon bundle_fileder.moon <dirname> <facets>... -- <children>...
{ dirname } = arg

assert dirname, "please specify the fileder dirname"

facets = {}
children_bundles = {}

do
  addto = facets
  for file in *arg[2,]
    if file == '--'
      addto = children_bundles
      continue
    table.insert addto, file

-- dump a fileder subtree as Lua source
dump_fileder = do
  escape = (str) -> string.format '%q', tostring str

  compile = (old, new, val) -> escape "-- this property has been transpiled from '#{old}'
-- to '#{new}' for execution in the browser.
-- refer to the original property as the source.
#{to_lua val}"

  _dump = (fileder, root=false) ->
    code = "Fileder {"

    for key, val in pairs fileder.props
      code ..= "\n[#{escape key}] = #{escape val},"

      if root and key.type\match '^text/moonscript %->'
        newkey = Key key.name, key.type\gsub '^text/moonscript %-> (.*)', 'text/lua -> %1'
        code ..= "\n[fromcache(#{escape newkey}, #{escape key})] = #{compile key, newkey, val},"

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

import Fileder from require 'mmm.mmmfs.fileder'
import opairs from require 'mmm.ordered'

with io.open '$bundle.lua', 'w'
  \write dump_fileder with Fileder 'name: alpha': dirname
    order = nil
    children = {}

    for facet in *facets
      if facet == '$order'
        order = [line for line in io.lines facet]
        continue
      key, value = load_property '', facet
      .props[key] = value

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
