local comp = require 'mmm.component'
local div, input, br = comp.elements.div, comp.elements.input, comp.elements.br

local text = comp.ReactiveVar "your text here"

return div{
  input{
    value = text:get(),
    oninput = function (_, e)
      text:set(e.target.value)
    end,
  },
  br(),
  input{
    disabled = true,
    value = text,
  },
}
