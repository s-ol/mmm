local comp = require 'mmm.component'
local div, button = comp.elements.div, comp.elements.button

local count = comp.ReactiveVar(0)

return div {
  button {
    '-',
    onclick = function () count:set(count:get() - 1) end
  },
  " count is: ",
  count:map(comp.text),
  " ",
  button {
    '+',
    onclick = function () count:set(count:get() + 1) end
  },
}
