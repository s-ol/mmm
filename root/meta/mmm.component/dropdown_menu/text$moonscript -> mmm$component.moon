import ReactiveVar, text, elements from require 'mmm.component'
import div, select, option from elements

color = ReactiveVar 'white'

div {
  div 'test', style: color\map (background) ->
    { padding: '1em', :background }

  select {
    onchange: (e) => color\set e.target.value

    option 'white'
    option 'red'
    option 'green'
  }
}
