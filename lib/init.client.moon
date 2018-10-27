export MODE, print, warn, relative, append, on_client
export window, document

window = js.global
{ :document, :console } = window

MODE = 'CLIENT'
print = console\log
warn = console\warn

package.path = '/?.shared.moon.lua;/?.client.moon.lua;/?.moon.lua;/?/init.moon.lua;/?.lua;/?/init.lua'

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
