export MODE, UNSAFE, print, warn, relative, on_load
export window, document

window = js.global
{ :document, :console } = window

MODE = 'CLIENT'
UNSAFE = true

deep_tostring = (tbl, space='', recur={}) ->
  buf = space .. tostring tbl

  return buf unless 'table' == (type tbl) and not tbl.__tostring and not recur[tbl]

  recur[tbl] = true
  buf = buf .. ' {\n'
  for k,v in pairs tbl
    buf = buf .. "#{space} [#{k}]: #{deep_tostring v, space .. '  ', recur}\n"
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

if on_load
  for f in *on_load do f!

on_load = setmetatable {}, __newindex: (t, k, v) ->
  rawset t, k, v
  v!
