import div, h3, ul, li, a, h4, img, p from require 'mmm.dom'

=>
  div {
    h3 @gett 'title: text/plain', style: { 'margin-bottom': '-.5em' },
    ul with for child in *@children
        link_if_content = (opts) ->
          a with opts
            if true or child\find 'mmm/dom'
              .style = { 'text-decoration': 'none' }
              .href = child.path
              .onclick

        li link_if_content {
          h4 {
            style: { 'margin-bottom': 0 }
            (child\get 'title: mmm/dom') or child\gett 'name: alpha'
          }
          div {
            style: {
              display: 'flex'
              'justify-content': 'space-around'
            }
            img src: child\gett 'icon: URL -> image/.*'
            p (child\gett 'description: mmm/dom'), style: { 'flex': '1 0 0', margin: '1em' }
          }
        }

      .style = {
        'list-style': 'none'
      }
  }
