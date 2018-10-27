require = relative ..., 1

Fileder {
  -- main content
  -- doesn't have a name prefix (e.g. preview: moon -> mmm/dom)
  -- uses the 'moon' interp to execute the lua/moonscript function on get
  -- resolves to a value of type mmm/dom
  'moon -> mmm/dom': () =>
    html = require 'lib.html'
    import article, h1, h2, h3, p, div, a, sup, ol, li, span, code, pre, br from html

    code = do
      _code = code
      (str) -> _code str\match '^ *(..-) *$'

    article with  _this = {}
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

      append h1 'mmmfs', style: { 'margin-bottom': 0 }
      append p "a file-, operating, and living system", style: { 'margin-top': 0, 'margin-bottom': '1em' }

      append p do
        fileder = footnote "fileder: file + folder. 'node', 'table' etc. are too general to be used all over."
        child = footnote "fileders can have multiple values, like the mentioned script, but these are not considered
          children of the fileder, as they are not fileders themselves. One fileder can have many values of different
          types/keys associated, but these have unspecified schemas and don't nest. In addition it can have many
          children, which are fileders themselves and can nest, but they are not labelled."

        "in mmmfs, directories are files and files are directories, or something like that.
        Listen, I don't really know yet either. The idea is that every node knows how to display it's contents;
        so for example your 'Pictures' fileder", fileder, " contains a script within itself that renders
        all the picture files you put into it at the children level", child, "."

      append p "a fileder should also be responsible for how it's children are sorted, filtered and interacted with.
        For example you should be able to create a fileder that is essentially a 'word document' equivalent: it could
        contain images, websites, links and of course text as children and let you reorder, layout and edit them in
        it's own edit interface."

      append p "a picture fileder could have an alternate slideshow view, or one that shows your geotagged images on a
        world map, if you really want that. Maybe you could build a music folder that contains links to youtube videos,
        spotify tracks and just plain mp3 files, and the folder knows how to play them all.", br!,
        "Sounds cool, no?"

      append h2 "details"
      append do
        mmmdom = code ('mmm/dom'), footnote span (code 'mmm/dom'), " is a polymorphic content type;
          on the server it is just an HTML string (like ", (code 'text/html'), "),
          but on the client it is a JS DOM Element instance."
        fengari = a 'fengari.io', href: 'https://fengari.io'
        p "What you are viewing right now is a fileder that has a Lua/Moonscript function as a value which
          is rendering all this text. It returns a value whose type interface is known as ", mmmdom, ", which is
          basically an HTML subtree. The function can be run, and the results generated, statically on the server
          (resulting in an HTML file), or dynamically on the client (via ", fengari, ").", br!,
          "The function is passed the fileder itself (as a Lua table) and potentially also receives some other
          helpers for accessing it's environment (parent fileders, functions for querying the tree etc) or info
          specific to the function key/type, but I haven't built or thought about any of that yet. Sorry."

      append do
        github = footnote a 's-ol/mmm', href: 'https://github.com/s-ol/mmm/tree/master/app/mmmfs'
        p "Anyway, this node is set up as some sort of wiki/index thing and just lists its children-fileders' ", (code 'title: text/plain'),
          " values and ", (code 'preview: mmm/dom'), " previews (if set). Oh and also everything is on github and stuff", github,
          " if you care about that."

      append p "Here's the Children:"

      -- render a preview block
      preview = (title, content, name) -> div {
        h3 title, style: { margin: 0, cursor: 'pointer' }, onclick: -> BROWSER\navigate { name }
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

      append div for child in *@children
        -- get 'title' as 'text/plain' (error if no value or conversion possible)
        title = child\gett 'title', 'text/plain'

        -- get 'preview' as a DOM description (nil if no value or conversion possible)
        content = child\get 'preview', 'mmm/dom'

        -- get 'preview' as a DOM description (nil if no value or conversion possible)
        name = child\gett 'name', 'alpha'

        preview title, content, name

      append h3 "converts"
      append p "Well actually it's a bit more complex. You see, the code that renders these previews ", (html.i "asks"), " for those
        name/type pairs (", (code 'title: text/plain'), ', ', (code 'preview: mmm/dom'), "), but the values don't actually have to
        be ", (html.i "defined"), " as these types."

      append pre code [[
-- render a preview block
preview = (title, content) -> div {
  h3 title, style: { ... },
  content or span '(no renderable content)', style: { ... },
  style: { ... }
}

append div for child in *@children
  -- get 'title' as 'text/plain' (error if no value or conversion possible)
  title = child\gett 'title', 'text/plain'

  -- get 'preview' as a DOM description (nil if no value or conversion possible)
  content = child\get 'preview', 'mmm/dom'

  preview title, content
      ]]

      append p "For example, the markdown child below only provides ", (code 'preview'), " as ", (code 'text/markdown'), ":"

      append pre code [[
Fileder {
  'title: text/plain': "I'm not even five lines of markdown but i render myself!",
  'preview: text/markdown': "See I have like

- a list of things
- (two things)

and some bold **text** and `code tags` with me.",
}
      ]]

      append p "Then, globally, there are some conversion paths specified; such as one that maps from ",
        (code 'text/markdown'), " to ", (code 'mmm/dom'), ":"

      append pre code [[
table.insert converts, {
  inp: 'text/markdown',
  out: 'mmm/dom',
  transform: (md) ->
    -- polymorphic client/serverside implementation here,
    -- uses lua-discount on the server, marked.js on the client
}
      ]]

      append h3 "interps"
      append p "In addition, a property can be encoded using ", (code 'interps'), ". For example the root node you are viewing
        currently is defined as ", (code 'moon -> mmm/dom'), ", meaning it is to be interpreted by the ", (code 'moon'),
        " interp before being treated as a regular ", (code 'mmm/dom'), " value."

      append p "The ", (code 'moon'), " interp takes a function value and calls it, passing the Fileder it is processing as ",
        (code 'self'), ":"

      append pre code [[
{
  name: 'moon',
  transform: (method) => method @
}
      ]]

      append p "Both interps and converts are resolved automatically when asking for values, so this page is being
        rendered just using ", (code "append root\\get 'mmm/dom'"), " as well."

      append h3 "interp overloading"
      append p "The example with the image is curious as well. In mmmfs, you might want to save a link to an image,
        without ever saving the actual image on your hard drive (or wherever the data may ever be stored - it is
        quite transient currently). The image Fileder below has it's main (unnamed) value tagged as ",
        (code 'URL -> image/png'), " - a png image, encoded as an URL. When accessed as ", (code 'image/png'), "
        the URL should be resolved, and the binary data provided in it's place (yeah right - I haven't build that yet).
        However, if a script is aware of URLs and knows a better way to handle them, then it can overload the URL
        interp for it's fetch, to get at the raw data and use that URL instead. This is what the image demo does in
        order to pass the URL to an ", (code 'img'), " tag's ", (code 'src'), " attribute:"

      append pre code [[
Fileder {
  'title: text/plain': "Hey I'm like a link to picture or smth",
  'URL -> image/png': 'https://picsum.photos/200?random',
  'preview: moon -> mmm/dom': =>
    import img from require 'lib.html'
    img src: @gett nil,               -- look for: main content
                   'image/png',       -- with image type, and
                   URL: (url) => url  -- override URL interp to get raw URL
}
      ]]

      append getnotes!

  'text/markdown': "this is a markdown version or something.

There's no content here so switch back to the real one!
(Assuming there is a switching UI by the time you are reading this, which I assume since you are reading this at all.
If you are reading this in the source, then c'mon, just scroll past and give me a break.)

(the switching UI has now been built.)"

  Fileder {
    'name: alpha': 'empty',
    'title: text/plain': "Hey I'm an ad-hoc child with no content for shit",
  }

  Fileder {
    'name: alpha': 'image',
    'title: text/plain': "Hey I'm like a link to picture or smth",

    -- main content is image/png, to be interpreted by URL to access
    'URL -> image/png': 'https://picsum.photos/200?random',

    -- preview is a lua/moonscript function that neturns an mmm/dom value
    'preview: moon -> mmm/dom': =>
      import img from require 'lib.html'
      img src: @gett nil,               -- look for: main content
                     'image/png',       -- with image type, and
                     URL: (url) => url  -- override URL interp to get raw URL
  }

  Fileder {
    'name: alpha': 'markdown',
    'title: text/plain': "I'm not even five lines of markdown but i render myself!",

    -- preview can be rendered using global convert
    'preview: text/markdown': "See I have like

- a list of things
- (two things)

and some bold **text** and `code tags` with me.",
  }

  -- if we are on client (mmm.s-ol.nu/?client=mmmfs), throw in twisted as a child
  if MODE == 'CLIENT' then require '.twisted'
}
