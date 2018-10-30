require = relative ...

import Fileder from require 'lib.mmmfs'

root = Fileder {
  -- main content
  -- doesn't have a name prefix (e.g. preview: moon -> mmm/dom)
  -- uses the 'moon ->' conversion to execute the lua/pre moon function on get
  -- resolves to a value of type mmm/dom
  'moon -> mmm/dom': () =>
    html = require 'lib.dom'
    import article, h1, h2, h3, p, div, a, sup, ol, li, span, code, pre, br from html

    moon = (str) ->
      result = window.hljs\highlight 'moonscript', (str\match '^ *(..-) *$'), true
      with code class: 'hljs'
        .innerHTML = result.value

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
      -- @TODO: s/filesystem/a way of organizing files/g
      append p "a file and operating system to live in", style: { 'margin-top': 0, 'margin-bottom': '1em' }

      -- @TODO: motivation / outline problem + need
      -- @TODO: quote http://pchiusano.github.io/2013-05-22/future-of-software.html on Applications

      append p do
        fileder = footnote "fileder: file + folder. 'node', 'table' etc. are too general to be used all over."

        -- @TODO: mention:
        -- can store anything - text, an image, a link to a website or video,
        -- a program and anything else you can think of.
        "in mmmfs, directories, files and applications are all kind of the same thing, or something like that.
        Listen, I don't really know yet either. The idea is that there is only one type of 'thing' -
        a fileder", fileder, ". A fileder can store multiple variants and metadata of its content,
        such as a markdown text and a rendered HTML version of the same document.
        It could also store a script that transforms the markdown version into HTML and is executed on demand,
        automatically."

      append p "Fileders can also have other fileders as their children (just like directories do in a normal
        filesystem). You can make a fileder view query these children and display them however you want.
        A 'Pictures' fileder, for example, could contain a script within itself that renders all the picture files
        you put into it as little previews and lets you click on them to view the full image."

      append p "This means the 'Pictures' fileder can also have an alternate slideshow mode, with fullscreen view and
        everything (some of this is built, check out the gallery example below), or one that displays geotagged images
        on a world map, if you really want that.  Maybe you could build a music folder that contains links to youtube
        videos, spotify tracks and just plain mp3 files, and the folder knows how to play them all.", br!, "
        In this way fileders fulfil the purpose of 'Applications' too."

      -- @TODO: BUT doesn't have to be only for one type of file:
      -- @TODO: rework
      -- making a multi-media collage representing your thoughts and mental organization of a topic
      append p "A fileder is also responsible for how it's children are sorted, filtered and interacted with.
        For example you should be able to create a fileder that is essentially a 'word document' equivalent: it can
        contain images, websites, links and of course text as children and let you reorder, layout and edit them
        whenever you open the fileder."

      append p "Sounds cool, no? Here's some examples of things a fileder can be or embed:"

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

        -- get 'name' as a DOM description (nil if no value or conversion possible)
        name = child\gett 'name', 'alpha'

        preview title, content, name

      append h2 "details"
      -- @TODO s/parts: dimensions, aspects?
      -- @TODO: first mention both properties & children; then go into detail
      -- @TODO: main content
      append do
        name = html.i 'name'
        type = html.i 'type'

        p "Fileders are made up of two main parts. The first is the list of ", (html.i 'properties'), ",
        which are values identified by a ", name, " and ", type, ". These values are queried using strings like ",
        (code 'title: text/plain'), " or ", (code 'mmm/dom'), ", which describe both the ", name,
        " of a property (", (moon '"title"'), " and ", (moon '""'), ", the unnamed/main property) and the ", type,
        " of a property. Property types can be something resembling a MIME-type or a more complex structure
        (see ", (html.i "type chains"), " below). A fileder can have multiple properties of different types
        set that share a ", name, ". In this case the overlapping properties are considered equivalent and the one
        with the most appropriate ", type, " is selected, depending on the query.
        The unnamed property is considered a fileder's 'main content', i.e. what you are interested in when viewing it."

      append p "The second part of a fileder is the list of it's children, which are fileders itself.
        The children are stored in an ordered list and currently identified by their ", (code 'name: alpha'),
        " property for UI and navigation purposes only (not sure if this is a good idea tbh)."

--      append do
--        github = footnote a 's-ol/mmm', href: 'https://github.com/s-ol/mmm/tree/master/app/mmmfs'
--          "Oh and also everything is on github and stuff", github,
--          " if you care about that."

      append do
        mmmdom = code ('mmm/dom'), footnote span (code 'mmm/dom'), " is a polymorphic content type;
          on the server it is just an HTML string (like ", (code 'text/html'), "),
          but on the client it is a JS DOM Element instance."

        p "What you are viewing right now is the main property of the root fileder.
          The property is queried as ", mmmdom, ", a website fragment (DOM node). This website fragment
          is then added to the page in the main content area, where you are most likely reading it right now."

        p "Anyway, this node is set up as a very generic sort of index thing and just lists its children-fileders' 
          alongside this text part you are reading.", br!, "For each child it displays the ", (code 'title: text/plain'),
          " and shows the ", (code 'preview: mmm/dom'), " property (if set)."

      append h3 "converts"
      append p "So far I have always listed properties as they are being queried, but a main feature of mmmfs is
        type conversion. This means that you generally ask for content in whichever format suits your application,
        and rely on the type resolution mechanism to make that happen."

      append pre moon [[
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

      append p "Here the code that renders these previews. You can see it ", (html.i "asks"), " for the
        properties ", (code 'title: text/plain'), ' and ', (code 'preview: mmm/dom'), "), but the values don't actually have to
        be ", (html.i "defined"), " as these types.
        For example, the markdown child below only provides ", (code 'preview'), " as ", (code 'text/markdown'), ":"

      append pre moon [[
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

      append pre moon [[
{
  inp: 'text/markdown',
  out: 'mmm/dom',
  transform: (md) ->
    -- polymorphic client/serverside implementation here,
    -- uses lua-discount on the server, marked.js on the client
}
      ]]

      append h3 "type chains"
      append p "In addition, a property type can be encoded using multiple types in a ", (code 'type chain'), ".
        For example the root node you are viewing currently is actually defined as ", (code 'moon -> mmm/dom'), ",
        meaning it's value is a pre moon function returing a regular ", (code 'mmm/dom'), " value."

      append p "Both value chains and 'sideways' converts are resolved using the same mechanism,
        so this page is being rendered just using ", (moon "append root\\get 'mmm/dom'"), " as well.
        The convert that resolves the moon type is defined as follows:"

      append pre moon [[
{
  inp: 'moon -> (.+)',
  out: '%1',
  transform: (val, fileder) -> val fileder
}
      ]]

      append p "The example with the image is curious as well. In mmmfs, you might want to save a link to an image,
        without ever saving the actual image on your hard drive (or wherever the data may ever be stored - it is
        quite transient currently). The image Fileder below has it's main (unnamed) value tagged as ",
        (code 'URL -> image/png'), " - a png image, encoded as an URL. When accessed as ", (code 'image/png'), "
        the URL should be resolved, and the binary data provided in it's place (yeah right - I haven't build that yet)."

      append p "However, if a script is aware of URLs and knows a better way to handle them, then it can ask for and
        use the URL directly instead.
        This is what the image demo does in order to pass the URL to an ", (code 'img'), " tag's ", (code 'src'), " attribute:"

      append pre moon [[
Fileder {
  'title: text/plain': "Hey I'm like a link to picture or smth",
  'URL -> image/png': 'https://picsum.photos/200?random',
  'preview: moon -> mmm/dom': =>
    import img from require 'lib.dom'
    img src: @gett 'URL -> image/png' -- look for main content with 'URL to png' type
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
    'title: text/plain': "Hey I'm an ad-hoc child with no content at all",
  }

  Fileder {
    'name: alpha': 'image',
    'title: text/plain': "Hey I'm like a link to picture or smth",

    -- main content is image/png, to be interpreted by URL to access
    'URL -> image/png': 'https://picsum.photos/200?random',

    -- preview is a lua/pre moon function that neturns an mmm/dom value
    'preview: moon -> mmm/dom': =>
      import img from require 'lib.dom'
      img src: @gett 'URL -> image/png' -- look for main content with 'URL to png' type
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

  require '.gallery',

  -- if we are on client, throw in twisted as a child
  if MODE == 'CLIENT' then require '.twisted'
}

if MODE == 'CLIENT'
  import Browser from require 'lib.mmmfs.browser'

  export BROWSER
  BROWSER = Browser root
  append BROWSER.node
else
  append root\get 'mmm/dom'
