import div, h3, p, ul, li, a from require 'mmm.dom'
import link_to from (require 'mmm.mmmfs.util') require 'mmm.dom'

=>
  div {
    link_to @
    p @gett 'description: mmm/dom', style: { 'margin-bottom': '-.5em' },
    div with for child in *@children
        name = child\gett 'name: alpha'
        desc = child\get 'description: mmm/dom'
        li {
          style: {
            display: 'inline-block'
            width: '500px'
            margin: '0.5em'
            padding: '1em'
            background: 'var(--gray-bright)'
          }
          child\get 'mmm/dom'
          div link_to child
        }

      .style = {
        display: 'flex'
        'flex-wrap': 'wrap'
        'align-items': 'flex-start'
      }
  }
