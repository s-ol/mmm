local component = require 'mmm.component'
local ReactiveVar, text, e = component.ReactiveVar, component.text, component.elements

local parent = e.div()
local function todoItem(desc, done)
  -- convert into reactive data sources
  local desc, done = ReactiveVar(desc), ReactiveVar(done)
  local me = e.div{
    style = {
      margin = '8px',
      padding = '8px',
      background = '#eeeeee',
    },
    e.h3{ desc:map(text), style = 'margin: 0;' },
    e.span(done:map(function (done)
      if done then
        return text 'done'
      else
        return text 'not done yet'
      end
    end)),
    e.input{ type = 'checkbox', checked = done, onchange = function(_, e) done:set(e.target.checked) end },
    e.a{ text 'delete', href = '#', onclick = function() parent:remove(me) end }
  }
  return me
end

parent:append(todoItem('write a Component System', true))
parent:append(todoItem('eat Lasagna', true))
parent:append(todoItem('do other things'))

local desc = ReactiveVar 'start'
local form = e.form{
  action = '',
  style = { margin = '2px' },
  onsubmit = function(_, e)
    e:preventDefault()
    parent:append(todoItem(desc:get()))
    desc:set ''
  end,
}
form:append(e.input{ type = 'text', value = desc, onchange = function(_, e) desc:set(e.target.value) end })
form:append(e.input{ type = 'submit', value = 'add' })

return e.article(parent, form)
