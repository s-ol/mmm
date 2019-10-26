import div, h1, a, img, br from require 'mmm.dom'

=>
  link = (child) -> a {
    href: '#',
    onclick: -> BROWSER\navigate child.path
    img src: child\gett 'preview', 'URL -> image/png'
  }

  content = [link child for child in *@children]
  table.insert content, 1, h1 'gallery index'
  div content
