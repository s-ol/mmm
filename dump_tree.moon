package.moonpath = './?.server.moon;./?/init.server.moon;' .. package.moonpath
require 'mmm.init'
import Key from require 'mmm.mmmfs'
import load_fileder from require 'mmm.mmmfs.fs'
import to_lua from require 'moonscript.base'

-- usage:
-- moon render.moon <output> [fileder_path]
{ output_name, path } = arg

assert output_name, "please specify the output filename as an argument"
path or= '/'

root = load_fileder 'root' .. path
root\mount path

-- dump a fileder subtree as Lua source
dump_fileder = do
  escape = (str) -> string.format '%q', tostring str

  _dump = (fileder) ->
    code = "Fileder {"

    for key, val in pairs fileder.props
      code ..= "
        [#{escape key}] = #{escape val},"

      if key.type\match '^text/moonscript %->'
        newkey = Key key.name, key.type\gsub '^text/moonscript %-> (.*)', 'text/lua -> %1'
        code ..= "
          [#{escape newkey}] = #{escape to_lua val},"

    for child in *fileder.children
      code ..= "
        #{_dump child},"

    code ..= "
      }"
    code


  (fileder) -> "
    local Fileder = (require 'mmm.mmmfs').Fileder

    return #{_dump fileder}
  "

with io.open output_name, 'w'
  \write dump_fileder root
