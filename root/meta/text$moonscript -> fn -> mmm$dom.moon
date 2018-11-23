import div, h3, p, br, ul, li, i from require 'mmm.dom'
import link_to from (require 'mmm.mmmfs.util') require 'mmm.dom'

=> div {
    style: { 'max-width': '700px' }
    h3 link_to @
    p "mmm is a collection of Lua/Moonscript modules for web development.
      All modules are 'polymorphic' - they can run in the ", (i 'browser'),
      ", using the native browser API for creating and interacting with DOM content, as well as on the ",
      (i 'server'), ", where they operate on and produce equivalent HTML strings."
    p "As the two implementations of each module are designed to be compatible,
      mmm facilitates code and content sharing between server and client
      and enables serverside rendering and rehydration."
    ul for child in *@children
      desc = child\gett 'description: mmm/dom'
      li (link_to child), ': ', desc
  }
