=>
  html = require 'mmm.dom'
  import div, h1, ol, li from html

  refs = for ref in *@children
    li ref\gett 'mmm/dom'
  div {
    h1 "references", id: 'references'
    ol with refs
      refs.style = 'line-height': 'normal'
  }
