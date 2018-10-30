export MODE, print, warn, relative, append, on_client
export window, document

window = js.global
{ :document, :console } = window

MODE = 'CLIENT'

deep_tostring = (tbl, space='') ->
  buf = space .. tostring tbl

  return buf unless 'table' == type tbl

  buf = buf .. ' {\n'
  for k,v in pairs tbl
    buf = buf .. "#{space} [#{k}]: #{deep_tostring v, space .. '  '}\n"
  buf = buf .. "#{space}}"
  buf

print = (...) ->
  contents = [deep_tostring v for v in *{ ... } ]
  console\log table.unpack contents

warn = (...) ->
  contents = [deep_tostring v for v in *{ ... } ]
  console\warn table.unpack contents

package.path = '/?.client.moon.lua;/?.moon.lua;/?/init.moon.lua;/?.lua;/?/init.lua'

-- relative imports
relative = do
  _require = require

  (base, sub) ->
    sub = 0 unless 'number' == type sub

    for i=1, sub
      base = base\match '^(.*)%.%w+$'

    (name, x) ->
      name = base .. name if '.' == name\sub 1, 1
      _require name

append = document.body\appendChild
on_client = (f, ...) -> f ...
