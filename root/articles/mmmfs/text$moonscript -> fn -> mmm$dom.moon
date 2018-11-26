-- main content
-- doesn't have a name prefix (e.g. preview: fn -> mmm/dom)
-- uses the 'fn ->' conversion to execute the lua function on @get
-- resolves to a value of type mmm/dom
=>
  html = require 'mmm.dom'
  import article, h1, h2, h3, p, div, a, sup, ol, li, span, code, pre, br from html
  import moon from (require 'mmm.highlighting').languages

  article with _this = {}
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

    -- @TODO: s/filesystem/a way of organizing files/g
    append h1 'mmmfs', style: { 'margin-bottom': 0 }
    append p "a file and operating system to live in", style: { 'margin-top': 0, 'padding-bottom': '0.2em', 'border-bottom': '1px solid black' }

    append h2 "motivation"
    append p "Today, computer users are losing more and more control over their data. Between web and cloud
      applications holding customer data hostage for providing the services, unappealing and limited mobile file
      browsing experiences and the non-interoperable, proprietary file formats holding on to their own data has
      become infeasible for many users. mmmfs is an attempt at rethinking file-systems and the computer user
      experience to give control back to and empower users."

    append p "mmmfs tries to provide a filesystem that is powerful enough to let you use it as your canvas for thinking,
      and working at the computer.  mmmfs is made for more than just storing information. Files in mmmfs can interact
      and morph to create complex behaviours."

    append p "Let us take as an example the simple task of collecting and arranging a mixed collection of images, videos
      and texts in order to brainstorm. To create an assemblage of pictures and text, many might be tempted to open an
      Application like Microsoft Word or Adobe Photoshop and create a new document there. Both photoshop files and
      word documents are capable of containing texts and images, but when the files are saved, direct access to the
      contained data is lost. It is for example a non-trivial and unenjoyable task to edit an image file contained
      in a word document in another application and have the changes apply to the document. In the same way,
      text contained in a photoshop document cannot be edited in a text editor of your choice."

    append p "mmmfs tries to change all this. In mmmfs, files can contain other files and so the collage document
      becomes a container for the collected images and texts just as a regular directory would. This way the individual
      files remain accessible and can be modified whenever necessary, while the collage document can be edited to
      change the order, sizes and spatial arrangement of it's content if this is wanted, for example."

    append p "The mmmfs file-type system also allows storing types of information that have become impractical to use
      with current filesystems simply because noone has cared to make suitable applications for them. It is not common
      practice, for example, to store direct links to online content on the disk for example. In mmmfs, a link to a
      picture can be stored wherever an actual picture is expected for example, the system will take care of retrieving
      the real picture as necessary."

    -- @TODO: motivation / outline problem + need
    -- * applications don't let users *do* things (http://pchiusano.github.io/2013-05-22/future-of-software.html)
    -- * applications are just (collections of) files - most users don't know this (anymore)
    -- * users should know their system and how to move around in it
    -- * filesystem trees are only *okay* for organizing information:
    --   - users sooner or later choose something smarter because:
    --  * filesystems work the same in every folder, even though the context can be very different
    --  * appliances put their complex, structured data into opaque blocks
    --    * the FS should be able to solve the structure issue
    --    * the benefit is interoperability: edit the image of your report
    --    * in image editor while the document editor automatically refreshes
    -- * file formats dont mean much to users, they are meant for applications - let applications take care of converting them
    -- * report.doc, report.pdf, report_orignal.pdf, report_old.doc, report2.doc....

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
    preview = (child) ->
      -- get 'title' as 'text/plain' (error if no value or conversion possible)
      title = child\gett 'title', 'text/plain'

      -- get 'preview' as a DOM description (nil if no value or conversion possible)
      content = child\get 'preview', 'mmm/dom'

      div {
        h3 title, style: { margin: 0, cursor: 'pointer' }, onclick: -> BROWSER\navigate child.path
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
      preview child

    append h2 "details"
    -- @TODO s/parts: dimensions, aspects?
    -- @TODO: first mention both facets & children; then go into detail
    -- @TODO: main content
    append do
      name = html.i 'name'
      type = html.i 'type'

      p "Fileders are made up of two main parts. The first is the list of ", (html.i 'facets'), ",
      which are values identified by a ", name, " and ", type, ". These values are queried using strings like ",
      (code 'title: text/plain'), " or ", (code 'mmm/dom'), ", which describe both the ", name,
      " of a facet (", (moon '"title"'), " and ", (moon '""'), ", the unnamed/main facet) and the ", type,
      " of a facet. Facet types can be something resembling a MIME-type or a more complex structure
      (see ", (html.i "type chains"), " below). A fileder can have multiple facets of different types
      set that share a ", name, ". In this case the overlapping facets are considered equivalent and the one
      with the most appropriate ", type, " is selected, depending on the query.
      The unnamed facet is considered a fileder's 'main content', i.e. what you are interested in when viewing it."

    append p "The second part of a fileder is the list of it's children, which are fileders itself.
      The children are stored in an ordered list and currently identified by their ", (code 'name: alpha'),
      " facet for UI and navigation purposes only (not sure if this is a good idea tbh)."

    append do
      mmmdom = code ('mmm/dom'), footnote span (code 'mmm/dom'), " is a polymorphic content type;
        on the server it is just an HTML string (like ", (code 'text/html'), "),
        but on the client it is a JS DOM Element instance."

      p "What you are viewing right now is the main facet of the root fileder.
        The facet is queried as ", mmmdom, ", a website fragment (DOM node). This website fragment
        is then added to the page in the main content area, where you are most likely reading it right now."

      p "Anyway, this node is set up as a very generic sort of index thing and just lists its children-fileders' 
        alongside this text part you are reading.", br!, "For each child it displays the ", (code 'title: text/plain'),
        " and shows the ", (code 'preview: mmm/dom'), " facet (if set)."

    append h3 "converts"
    append p "So far I have always listed facets as they are being queried, but a main feature of mmmfs is
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
      facets ", (code 'title: text/plain'), ' and ', (code 'preview: mmm/dom'), "), but the values don't actually have to
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
    append p "In addition, a facet type can be encoded using multiple types in a ", (code 'type chain'), ".
      For example the root node you are viewing currently is actually defined as ", (code 'fn -> mmm/dom'), ",
      meaning it's value is a pre moon function returing a regular ", (code 'mmm/dom'), " value."

    append p "Both value chains and 'sideways' converts are resolved using the same mechanism,
      so this page is being rendered just using ", (moon "append root\\get 'mmm/dom'"), " as well.
      The convert that resolves the moon type is defined as follows:"

    append pre moon [[
{
  inp: 'fn -> (.+)',
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
  'preview: fn -> mmm/dom': =>
    import img from require 'mmm.dom'
    img src: @gett 'URL -> image/png' -- look for main content with 'URL to png' type
}
    ]]

    append getnotes!
