import div, h3, ul, li, a from require 'mmm.dom'

=>
  div {
    h3 @gett 'title: text/plain', style: { 'margin-bottom': '-.5em' },
    ul for child in *@children
      name = child\gett 'name: alpha'
      desc = child\gett 'description: text/plain'
      li {
        a name, {
          href: child.path,
          onclick: (e) =>
            e\preventDefault!
            BROWSER\navigate child.path
        },
        ': ', desc
      }
  }
