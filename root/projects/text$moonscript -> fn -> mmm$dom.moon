import div, h3, ul, li from require 'mmm.dom'
import link_to from (require 'mmm.mmmfs.util') require 'mmm.dom'

=>
  div {
    link_to @, h3 @gett 'title: text/plain', style: { 'margin-bottom': '-.5em' },
    ul for child in *@children
      desc = child\gett 'description: mmm/dom'
      li (link_to child), ': ', desc
  }
