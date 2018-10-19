export MODE, print, warn, relative, append, on_client
export window, document

window = js.global
{ :document, :console } = window

MODE = 'CLIENT'
print = console\log
warn = console\warn

-- package.path = './?.shared.lua;./?.client.lua;' .. package.path
package.path = './?.shared.moon.lua;./?.client.moon.lua;./?.moon.lua;./?/init.moon.lua;./?.lua;./?/init.lua'

-- relative imports
relative = (...) ->
  path = ...

  (name) ->
    name = path .. name if '.' == name\sub 1, 1
    require name

append = document.body\appendChild
on_client = (f, ...) -> f ...
