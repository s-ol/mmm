moon = require 'moonscript.base'

output_name = assert arg[1], "please specify the output directory"

escape = (str) ->
  string.format '%q', str

readfile = (name) ->
  file = io.open name, 'r'
  with file\read '*all'
    file\close

out = io.open output_name, 'w'
out\write "
local p = {}
table.insert(package.searchers, 1, function (mod)
  print('?',mod, not not p[mod])
  local mod = p[mod]
  return mod and function ()
    return load(table.unpack(mod))()
  end
end)
"

for file in io.lines!
  module = file\gsub '%.moon$', ''
  continue if not module or module\match '%.server'
  module = module\gsub '%.client$', ''
  module = module\gsub '/init$', ''
  module = module\gsub '/', '.'
  module = escape module
  source = moon.to_lua readfile file
  out\write "p[#{module}] = {#{escape source}, #{escape file}}\n"

out\close!
