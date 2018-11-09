import article, h1, p, ul, li, a from require 'mmm.dom'

single = (a) -> a

=>
  children = for child in *@children
    title = child\gett 'title: text/plain'
    li a title, href: child.path, onclick: (e) =>
      e\preventDefault!
      BROWSER\navigate child.path

  article {
    h1 single @gett 'title: text/plain'
    p single @gett 'preview: mmm/dom'
    ul children
  }
