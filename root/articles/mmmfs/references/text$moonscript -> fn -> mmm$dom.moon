=>
  html = require 'mmm.dom'
  import div, h1, ol, li from html

  div {
    h1 "references"
    ol for ref in *@children
      li ref\gett 'mmm/dom'
  }
