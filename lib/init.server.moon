export MODE, warn, relative, append, on_client
MODE = 'SERVER'

-- warning messages
warn = (...) ->
  io.stderr\write table.concat { ... }, '\t'
  io.stderr\write '\n'

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

-- shorthand to append elements to body
buffer = ''
append = (val) ->
  buffer ..= val

import compile, insert_loader from require 'duct_tape'
insert_loader!

on_client = (fn, ...) ->
  args = {...}
  -- warn code
  append "<script type=\"application/lua\">
    local fn = #{compile fn}
    fn(#{table.concat [string.format '%q', v for v in *args ], ', '})
  </script>"

{
  -- access / flush the appended data
  flush: ->
    with x = buffer
      buffer = ''
}
