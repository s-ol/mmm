import div, img, br from require 'mmm.dom'

=> div {
  'the first pic as a little taste:',
  br!,
  img src: @children[1]\get 'preview', 'URL -> image/png'
}
