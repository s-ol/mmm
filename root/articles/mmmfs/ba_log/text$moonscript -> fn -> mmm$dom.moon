import div, h1, ul, li from require 'mmm.dom'
import link_to from (require 'mmm.mmmfs.util') require 'mmm.dom'
import ropairs from require 'mmm.ordered'

=>
  div {
    h1 (link_to @, "appendix: project log"), id: 'ba-log'
    @gett 'intro: mmm/dom'
    ul do
      posts = for post in *@children
        continue if post\get 'hidden: bool'
        li link_to post, post\gett 'name: mmm/dom'

      posts
  }
