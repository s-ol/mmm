import div, section, h1, h2, hr from require 'mmm.dom'
import link_to from (require 'mmm.mmmfs.util') require 'mmm.dom'
import ropairs from require 'mmm.ordered'

=>
  div {
    class: 'print-ownpage'

    h1 (link_to @, "appendix: project log"), id: 'ba-log'
    @gett 'intro: mmm/dom'
    table.unpack for post in *@children
      continue if post\get 'hidden: bool'

      section {
        hr!
        h2 link_to post, post\gett 'name: mmm/dom'
        (post\gett 'mmm/dom')
      }
 }
