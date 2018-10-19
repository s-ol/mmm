export MODE, print, warn, relative, append, on_client
export window, document

window = js.global
document = window.document

MODE = 'CLIENT'
print = window.console\log
warn = window.console\warn

-- package.path = './?.shared.lua;./?.client.lua;' .. package.path
print package.path
package.path = './?.shared.moon.lua;./?.client.moon.lua;./?.moon.lua;./?/init.moon.lua;./?.lua;./?/init.lua'

-- relative imports
relative = (...) ->
  path = ...

  (name) ->
    name = path .. name if '.' == name\sub 1, 1
    require name

append = document.body\appendChild
on_client = (f, ...) -> f ...
