import div, h3, p, ul, li, a from require 'mmm.dom'

=>
  div {
    h3 @gett 'name: alpha', style: { 'margin-bottom': '-.5em' },
    p @gett 'description: mmm/dom', style: { 'margin-bottom': '-.5em' },
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
