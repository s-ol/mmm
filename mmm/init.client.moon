export MODE, UNSAFE, print, warn, relative, on_load
export window, document

window = js.global
{ :document, :console } = window

MODE = 'CLIENT'
UNSAFE = true

deep_tostring = (tbl, space='') ->
  return tbl if 'userdata' == type tbl

  buf = space .. tostring tbl
  return buf unless 'table' == (type tbl) and not tbl.__tostring

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

-- package.path = '/?.client.moon.lua;/?.moon.lua;/?/init.moon.lua;/?.lua;/?/init.lua'
package.path = '/?.lua;/?/init.lua'

-- relative imports
relative = do
  _require = require

  (base, sub) ->
    sub = 0 unless 'number' == type sub

    for i=1, sub
      base = base\match '^(.*)%.%w+$'

    (name, x) ->
      if name == '.'
        name = base
      else if '.' == name\sub 1, 1
        name = base .. name

      _require name

if on_load
  for f in *on_load do f!

on_load = setmetatable {}, __newindex: (t, k, v) ->
  rawset t, k, v
  v!
