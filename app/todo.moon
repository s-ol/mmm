{ :document } = js.global
import Callback, CallbackElement, text, div, form, span, h3, a, input, textarea, button from require './component.moon'

parent = div!
todoItem = (desc, done) ->
  -- convert into reactive data sources
  desc, done = (Callback desc), Callback done
  with me = div style:
      margin: '8px'
      padding: '8px'
      background: '#eeeeee'
    \append h3 style: 'margin: 0;', desc
    \append span done\chain (done) -> text if done then 'done' else 'not done yet'
    \append input type: 'checkbox', checked: done, onchange: (e) => done\set e.target.checked
    \append a href: '#', onclick: ((e) => parent\remove me), text 'delete'

parent\append todoItem 'write a Component System'
parent\append todoItem 'eat Lasagna', true

form = with form action: '', style: 'margin 2px;'
  desc = input type: 'text', value: 'start'
  \append desc
  \append input type: 'submit', value: 'add'
  \set 'onsubmit', (e) =>
    e\preventDefault!
    parent\append todoItem desc.node.value
    desc.node.value = ''

document.body\appendChild parent.node
document.body\appendChild form.node
