export MODE, print, warn, relative
MODE = 'SERVER'

deep_tostring = (tbl, space='') ->
  buf = space .. tostring tbl

  return buf unless 'table' == type tbl

  buf = buf .. ' {\n'
  for k,v in pairs tbl
    buf = buf .. "#{space} [#{k}]: #{deep_tostring v, space .. '  '}\n"
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

-- relative imports
relative = do
  _require = require

  (base, sub) ->
    sub = sub or 0

    for i=1, sub
      base = base\match '^(.*)%.%w+$'

    (name, x) ->
      if name == '.'
        name = base
      else if '.' == name\sub 1, 1
        name = base .. name

      _require name
