-- main content
-- doesn't have a name prefix (e.g. preview: fn -> mmm/dom)
-- uses the 'fn ->' conversion to execute the lua function on @get
-- resolves to a value of type mmm/dom
=>
  html = require 'mmm.dom'
  import h4, div, a, span from html

  -- render a preview block
  preview = (child) ->
    -- get 'title' as 'text/plain' (error if no value or conversion possible)
    title = child\gett 'title', 'text/plain'

    -- get 'preview' as a DOM description (nil if no value or conversion possible)
    content = child\get 'preview', 'mmm/dom'

    div {
      h4 title, style: { margin: 0, cursor: 'pointer' }, onclick: -> BROWSER\navigate child.path
      content or span '(no renderable content)', style: { color: 'red' },
      style: {
        display: 'inline-block',
        width: '300px',
        height: '200px',
        padding: '4px',
        margin: '8px',
        border: '4px solid #eeeeee',
        overflow: 'hidden',
      },
    }

  div for child in *@children
    preview child
