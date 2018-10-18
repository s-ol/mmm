export MODE, print, warn, relative, append, on_client
export window, document


window = js.global
document = window.document

MODE = 'CLIENT'
print = window.console\log
warn = window.console\warn

print 'path is'
print package.path

package.path = './?.shared.lua;./?.client.lua;' .. package.path

-- relative imports
relative = (...) ->
  path = ...

  (name) ->
    name = path .. name if '.' == name\sub 1, 1
    require name

append = document.body\appendChild
on_client = (f, ...) -> f ...
