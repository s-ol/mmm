local comp = require 'mmm.component'
local e = comp.elements

local color = comp.ReactiveVar 'red'

return e.div {
  e.div { 'test', style = color:map(function (bg)
    return { padding = '1em', background = bg }
  end) },
  e.select {
    onchange = function (_, e) color:set(e.target.value) end,

    e.option 'red',
    e.option 'green',
    e.option 'blue',
  },
}
