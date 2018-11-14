import ReactiveVar, text, elements from require 'mmm.component'
import div, button from elements

count = ReactiveVar 0

div {
  button '-', onclick: () -> count\transform (c) -> c - 1
  " count is: "
  count\map text
  " "
  button '+', onclick: () -> count\transform (c) -> c + 1
}
