import div, h3, ul, li from require 'mmm.dom'
import link_to from (require 'mmm.mmmfs.util') require 'mmm.dom'

=>
  div {
    h3 link_to @
    ul for child in *@children
      desc = child\gett 'description: mmm/dom'
      li (link_to child), ': ', desc
  }
