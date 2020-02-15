-- main content
-- doesn't have a name prefix (e.g. preview: fn -> mmm/dom)
-- uses the 'fn ->' conversion to execute the lua function on @get
-- resolves to a value of type mmm/dom
=>
  html = require 'mmm.dom'
  import article, h1, p, div from html
  import moon from (require 'mmm.highlighting').languages

  article with _this = class: 'sidenote-container spacious', style: { 'max-width': '640px', 'line-height': '1.5' }
    append = (a) -> table.insert _this, a

    append div {
      h1 'Empowered End-User Computing', style: { 'margin-bottom': 0 }
      p {
        style:
          'margin-top': 0
          'padding-bottom': '0.2em'
          'border-bottom': '1px solid black'

        "A Historical Investigation and Development of a File-System-Based Environment"
      }
    }

    for child in *@children
      append (child\get 'print: mmm/dom') or (child\gett 'mmm/dom')
