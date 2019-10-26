import ReactiveVar, text, elements from require 'mmm.component'
import div, a, img from elements

=>
  index = ReactiveVar 1

  prev = (i) -> math.max 1, i - 1
  next = (i) -> math.min #@children, i + 1

  div {
    div {
      a 'prev', href: '#', onclick: -> index\transform prev
      index\map (i) -> text " image ##{i} "
      a 'next', href: '#', onclick: -> index\transform next
    },
    index\map (i) ->
      child = assert @children[i], "image not found!"
      img src: @children[i]\gett 'URL -> image/png'
  }
