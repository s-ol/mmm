import ReactiveVar, elements from require 'mmm.component'
import div, input, br from elements

text = ReactiveVar "your text here"

handler = (e) => text\set e.target.value

div {
  input value: text\get!, oninput: hander
  br!
  input disabled: true, value: text
}
