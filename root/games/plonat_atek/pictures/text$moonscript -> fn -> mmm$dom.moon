import div from require 'mmm.dom'
import embed from (require 'mmm.mmmfs.util') require 'mmm.dom'

=>
  images = for child in *@children
    embed child, nil, nil, attr: {
      style: {
        height: '15em'
        margin: '0 .5em'
      }
    }

  div with images
    .style = {
      display: 'flex'
      overflow: 'auto hidden'
    }
