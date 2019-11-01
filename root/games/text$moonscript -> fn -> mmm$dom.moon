import div, span, h3, ul, li, a, h4, img, p from require 'mmm.dom'
import link_to from (require 'mmm.mmmfs.util') require 'mmm.dom'
import ropairs from require 'mmm.ordered'

=>
  div {
    h3 link_to @
    ul do
      games = { (p\gett 'date: time/unix'), p for p in *@children }

      children = for k, child in ropairs games
        desc = child\gett 'description: mmm/dom'
        jam = if link = child\get 'jam: mmm/dom'
          span '[', link, ']', style: float: 'right', clear: 'right', color: 'var(--gray-dark)'

        li (link_to child), ': ', desc, jam

      children
--    ul with for child in *@children
--        link_if_content = (opts) ->
--          a with opts
--            if true or child\find 'mmm/dom'
--              .style = { 'text-decoration': 'none' }
--              .href = child.path
--              .onclick
--
--        li link_if_content {
--          h4 {
--            style: { 'margin-bottom': 0 }
--            (child\get 'title: mmm/dom') or child\gett 'name: alpha'
--          }
--          div {
--            -- style: {
--            --   display: 'flex'
--            --   'justify-content': 'space-around'
--            -- }
--            -- img src: child\gett 'icon: URL -> image/.*'
--            p (child\gett 'description: mmm/dom'), style: { 'flex': '1 0 0', margin: '1em' }
--          }
--        }
--
--      .style = {
--        'list-style': 'none'
--      }
  }
