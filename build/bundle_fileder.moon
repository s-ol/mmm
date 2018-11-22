require 'mmm'
import get_path from require 'build.util'
import Fileder, Key from require 'mmm.mmmfs.fileder'
import opairs from require 'mmm.ordered'
import to_lua from require 'moonscript.base'

-- usage:
-- moon bundle_fileder.moon <path_to_root> <dirname> <facets>... -- <children>...
{ path_to_root, dirname } = arg

assert path_to_root, "please specify the relative root path"
assert dirname, "please specify the fileder dirname"
path = get_path path_to_root

facets = {}
children_bundles = {}

do
  addto = facets
  for file in *arg[3,]
    continue if file == 'Tupdefault.lua'

    if file == '--'
      addto = children_bundles
      continue
    table.insert addto, file

-- load a fs file as a fileder facet
load_facet = (filename) ->
  key = (filename\match '(.*)%.%w+') or filename
  key = Key key\gsub '%$', '/'
  key.filename = filename

  file = assert (io.open filename, 'r'), "couldn't open facet file '#{filename}'"
  value = file\read '*all'
  file\close!

  key, value

-- escape a string for lua aparser
escape = (str) -> string.format '%q', tostring str

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

renders = {
  {
    inp: '^text/moonscript %-> (.*)'
    out: 'text/lua -> %1'
    render: (val, fileder, old, new) ->
      lua, err = to_lua val

      if not lua
        error "Error compiling #{old}: #{err}"

      "-- this moonscript facet has been transpiled to
-- '#{new}' for execution in the browser.
-- refer to the original facet as the source.
#{lua}"
  },
  {
    inp: '^image/'
    out: 'URL -> %0'
    render: (val, fileder, old, new) -> "#{fileder.path}/#{old.filename}", "[binary removed]"
  },
  {
    inp: '^video/'
    out: 'URL -> %0'
    render: (val, fileder, old, new) -> "#{fileder.path}/#{old.filename}", "[binary removed]"
  },
}

with io.open '$bundle.lua', 'w'
  \write dump_fileder with fileder = Fileder 'name: alpha': dirname
    \mount path, true

    order = nil
    children = {}

    for facet in *facets
      if facet == '$order'
        order = [line for line in io.lines facet]
        continue
      key, value = load_facet facet
      .facets[key] = value

    extra_facets = {}
    for key, value in pairs .facets
      for { :inp, :out, :render } in *renders
        continue unless key.type\match inp

        built_key = Key key.name, key.type\gsub inp, out
        built_key.original = key

        -- dont overwrite existing keys
        continue if \has built_key

        rendered, replace = render value, fileder, key, built_key

        extra_facets[built_key] = rendered
        .facets[key] = replace if replace

        break

    for k,v in pairs extra_facets
      .facets[k] = v

    for child in *children_bundles
      -- @BUG: child bundles are malformed due to Tup bug ($ symbol)
      child = child\gsub '/%.lua$', '/$bundle.lua'

      dirname = assert child\match '^([%w-_%.]+)/%$bundle%.lua$'
      children[dirname] = dofile child

    if order
      -- order from order file
      for i, name in pairs order
        child = assert children[name], "child in $order but not fs: #{name}"
        table.insert .children, child
        children[name] = nil

    -- sort remainder alphabeticalally
    for name, child in opairs children
      table.insert .children, child
      warn "child #{name} not in $order!" if order

  \close!
