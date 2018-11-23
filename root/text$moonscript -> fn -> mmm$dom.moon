import article, h1, h3, div, b, p, a, br, ul, tt, li, img from require 'mmm.dom'
import opairs from require 'mmm.ordered'

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
  }

  for child in *@children
    append div {
      class: 'well'
      (child\get 'preview: mmm/dom') or child\get 'mmm/dom'
    }

  finish!
