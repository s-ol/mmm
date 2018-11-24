import article, h1, h3, div, b, p, a, br, ul, tt, li, img from require 'mmm.dom'
import link_to from (require 'mmm.mmmfs.util') require 'mmm.dom'

=>
  append, finish = do
    content = {}

    append = (stuff) -> table.insert content, stuff
    append, -> article content

  append p {
    tt 'mmm'
    ' is not the '
    tt 'www'
    ', because it runs on '
    a { 'MoonScript', href: 'https://moonscript.org' }
    '.'
    br!
    'You can find the source code of everything '
    a { 'here', href: 'https://github.com/s-ol/mmm' }
    '.'
    br!
    'Most of the inner-workings of this page are documented in ',
    link_to @walk 'articles/mmmfs'
  }

  for child in *@children
    continue if child\get 'hidden: bool'
    append div {
      class: 'well'
      (child\get 'preview: mmm/dom') or child\get 'mmm/dom'
    }

  finish!
