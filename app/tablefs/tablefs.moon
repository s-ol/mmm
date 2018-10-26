Fileder {
  'moon -> mmm/dom': () =>
    import article, h1, h3, p, div, a, sup, ol, li, span, code, br from require 'lib.html'

    content = {}
    append = (stuff) -> table.insert content, stuff

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

    append h1 'Tablefs', style: { 'margin-bottom': 0 }
    append p "(it's a terrible name, isn't it)", style: { 'margin-top': 0, 'margin-bottom': '1em' }

    append p do
      fileder = footnote "fileder: file + folder. 'node', 'table' etc. are too general to be used all over."
      child = footnote "fileders can have multiple values, like the mentioned script, but these are not considered
        children of the fileder, as they are not fileders themselves. One fileder can have many values of different
        types/keys associated, but these have unspecified schemas and don't nest. In addition it can have many
        children, which are fileders themselves and can nest, but they are not labelled."

      "in Tablefs, directories are files and files are directories, or something like that.
      Listen, I don't really know yet either. The idea is that every node knows how to render it's contents;
      so for example your 'Pictures' fileder", fileder, " contains a script within itself that renders
      all the picture files you put into it at the children level", child, "."

    append p "What you are viewing right now is a fileder that has a value set at the ", (code 'moon -> text/html'), " key;
      That value is the Lua/Moonscript function that is generating this text.", br!,
      "The function is passed the fileder itself (as a Lua table) and potentially also receives some other
      helpers for accessing it's environment (parent fileders, functions for querying the tree etc) or info
      specific to the function key/type, but I haven't built or thought about any of that yet. Sorry."

    append do
      github = footnote a 's-ol/mmm', href: 'https://github.com/s-ol/mmm'
      p "Anyway, this node is set up as some sort of wiki/index thing and just lists its children-fileders' ", (code 'title: text/plain'),
        " values and ", (code 'preview: moon -> text/html'), " previews (if set). Oh and also everything is on github and stuff", github,
        " if you care about that."


    append p "Here's the Children:"

    mb_render = (child, key) ->
      if child[key]
        child[key] child

    title = (text) -> h3 text, style: { margin: 0 }

    append div for child in *@children
      div {
        title child\gett 'title', 'text/plain',
        (child\get 'preview', 'mmm/dom') or span '(no renderable content)', style: { color: 'red' }
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

    append getnotes!

    article content

  'text/markdown': "this is a markdown version or something.

There's no content here so switch back to the real one!
(Assuming there is a switching UI by the time you are reading this, which I am presupposing since you are reading this at all.
If you are reading this in the source, then c'mon, just scroll past and give me a break.)"

  Fileder {
    'title: text/plain': "Hey I'm an ad-hoc child with no content for shit",
  }

  Fileder {
    'title: text/plain': "Hey I'm like a link to picture or smth",
    'http -> image/png': 'https://picsum.photos/200?random',
    'preview: moon -> mmm/dom': =>
      import img from require 'lib.html'
      img src: @gett nil,                -- look for: main content
                    'image/png',        -- w/ image type, and
                    http: (...) => ...  -- override http interp to get URL
  }

  Fileder {
    'title: text/plain': "I'm not even five lines of markdown but i render myself!",
    'text/markdown': "See I have like

- a list of things
- (two things)

and some bold **text** and `code tags` with me.",
    'preview: moon -> text/markdown': => @get 'text/markdown' -- redirect to main content of same type, if exists
    'preview: text/html': '<p>on the client I\'m a HTML string.<br/> poor, <i>I know&hellip;</i></p>'
  }
}
