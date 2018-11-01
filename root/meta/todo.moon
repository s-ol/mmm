import define_fileders from require 'mmm.mmmfs'
Fileder = define_fileders ...

Fileder {
  'name: alpha': 'todo'
  'description: text/plain': 'TodoMVC using mmm.component'
  'moon -> mmm/component': =>
    import ReactiveVar, text, elements from require 'mmm.component'
    import article, div, form, span, h3, a, input, textarea, button from elements

    parent = div!
    todoItem = (desc, done) ->
      -- convert into reactive data sources
      desc, done = (ReactiveVar desc), ReactiveVar done
      with me = div style:
          margin: '8px'
          padding: '8px'
          background: '#eeeeee'
        \append h3 (desc\map text), style: 'margin: 0;'
        \append span done\map (done) -> text if done then 'done' else 'not done yet'
        \append input type: 'checkbox', checked: done, onchange: (e) => done\set e.target.checked
        \append a (text 'delete'), href: '#', onclick: (e) => parent\remove me

    parent\append todoItem 'write a Component System', true
    parent\append todoItem 'eat Lasagna', true
    parent\append todoItem 'do other things'

    desc = ReactiveVar 'start'
    form = with form {
        action: ''
        style:
          margin: '2px'
        onsubmit: (e) =>
          e\preventDefault!
          parent\append todoItem desc\get!
          desc\set ''
      }
      \append input type: 'text', value: desc, onchange: (e) => desc\set e.target.value
      \append input type: 'submit', value: 'add'

    article parent, form
}
