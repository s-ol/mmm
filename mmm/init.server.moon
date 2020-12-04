export MODE, print, warn, relative
MODE = 'SERVER'

deep_tostring = (tbl, space='', recur={}) ->
  buf = space .. tostring tbl

  return buf unless 'table' == (type tbl) and not tbl.__tostring and not recur[tbl]

  recur[tbl] = true
  buf = buf .. ' {\n'
  for k,v in pairs tbl
    buf = buf .. "#{space} [#{k}]: #{deep_tostring v, space .. '  ', recur}\n"
  buf = buf .. "#{space}}"
  buf

print = do
  _print = print
  (...) ->
    contents = [deep_tostring v for v in *{ ... } ]
    _print table.unpack contents

-- warning messages
warn = (...) ->
  contents = [deep_tostring v for v in *{ ... } ]
  io.stderr\write table.concat contents, '\t'
  io.stderr\write '\n'
