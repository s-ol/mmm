-- main content
-- doesn't have a name prefix (e.g. preview: fn -> mmm/dom)
-- uses the 'fn ->' conversion to execute the lua function on @get
-- resolves to a value of type mmm/dom
=>
  html = require 'mmm.dom'
  import article, h1, h2, h3, section, p, div, a, sup, ol, li, span, code, pre, br from html
  import moon from (require 'mmm.highlighting').languages

  article with _this = class: 'sidenote-container', style: { 'max-width': '640px' }
    append = (a) -> table.insert _this, a

    footnote, getnotes = do
      local *
      notes = {}

      id = (i) -> "footnote-#{i}"

      footnote = (stuff) ->
        i = #notes + 1
        notes[i] = stuff
        sup a "[#{i}]", style: { 'text-decoration': 'none' }, href: '#' .. id i

      footnote, ->
        args = for i, note in ipairs notes
          li (span (tostring i), id: id i), ': ', note
        notes = {}
        table.insert args, style: { 'list-style': 'none', 'font-size': '0.8em' }
        ol table.unpack args

    append h1 'Empowered End-User Computing', style: { 'margin-bottom': 0 }
    append p "A Historical Investigation and Development of a File-System-Based Environment", style: { 'margin-top': 0, 'padding-bottom': '0.2em', 'border-bottom': '1px solid black' }

    -- render a preview block
    do_section = (child) ->
      -- get 'title' as 'text/plain' (error if no value or conversion possible)
      title = (child\get 'title: text/plain') or child\gett 'name: alpha'

      -- get 'preview' as a DOM description (nil if no value or conversion possible)
      content = (child\get 'preview: mmm/dom') or child\get 'mmm/dom'

      section {
        h3 title, style: { margin: 0, cursor: 'pointer' }, onclick: -> BROWSER\navigate child.path
        content or span '(no renderable content)', style: { color: 'red' },
      }

    for child in *@children
      append child\gett 'mmm/dom'
      -- do_section child

    append getnotes!
