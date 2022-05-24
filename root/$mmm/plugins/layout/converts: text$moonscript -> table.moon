import header, aside, footer, div, svg, script, g, circle, h1, span, b, a, img from require 'mmm.dom'
import navigate_to from (require 'mmm.mmmfs.util') require 'mmm.dom'
import get_plugins from require 'mmm.mmmfs.meta'

pick = (...) ->
  num = select '#', ...
  i = math.ceil math.random! * num
  (select i, ...)

iconlink = (href, src, alt, style) -> a {
  class: 'iconlink',
  target: '_blank',
  rel: 'me',
  :href,
  img :src, :alt, :style
}

logo = svg {
  class: 'sun'
  viewBox: '-0.75 -1 1.5 2'
  xmlns: 'http://www.w3.org/2000/svg'
  baseProfile: 'full'
  version: '1.1'

  g {
    transform: 'translate(0 .18)'

    g { class: 'circle out', circle r: '.6', fill: 'none', 'stroke-width': '.12' }
    g { class: 'circle  in', circle r: '.2', stroke: 'none' }
  }
}

gen_header = ->
  header {
    div {
      h1 {
        navigate_to '', logo
        span {
          span 'mmmfs', class: 'bold'
          '&#8203;'
          '.s&#8209;ol.nu'
        }
      }
      "a hypermedia information system."
    }
  }

footer = footer {
  span {
    'made with \xe2\x98\xbd by '
    a 's-ol', href: 'https://s-ol.nu'
    ", #{os.date '%Y'}"
  }
  div {
    class: 'icons',
    iconlink 'https://github.com/s-ol', 'https://cdn.jsdelivr.net/npm/simple-icons@latest/icons/github.svg', 'github'
    iconlink 'https://merveilles.town/@s_ol', 'https://cdn.jsdelivr.net/npm/simple-icons@latest/icons/mastodon.svg', 'mastodon'
    iconlink 'https://twitter.com/S0lll0s', 'https://cdn.jsdelivr.net/npm/simple-icons@latest/icons/twitter.svg', 'twitter'
    iconlink 'https://webring.xxiivv.com/#random', 'https://webring.xxiivv.com/icon.black.svg', 'webring',
      { height: '1.3em', 'margin-left': '.3em', 'margin-top': '-0.12em' }
  }
}

get_header_tags = =>
  title = (@get 'title: text/plain') or @gett 'name: alpha'

  l = (str) ->
    str = str\gsub '[%s\n]+$', ''
    str\gsub '\n', ' '
  e = (str) -> string.format '%q', l str

  meta = "
    <meta charset=\"UTF-8\">
    <title>#{l title}</title>
  "

  if page_meta = @get '_meta: mmm/dom'
    meta ..= page_meta
  else
    meta ..= "
    <meta name=\"viewport\" content=\"width=device-width, initial-scale=1\">

    <meta property=\"og:title\" content=#{e title} />
    <meta property=\"og:type\"  content=\"website\" />
    <meta property=\"og:url\"   content=\"https://mmm.s-ol.nu#{@path}/\" />
    <meta property=\"og:site_name\" content=\"mmm\" />"

    if desc = @get 'description: text/plain'
      meta ..= "
    <meta property=\"og:description\" content=#{e desc} />"

  meta

get_scripts = =>
  scripts = ''
  for plugin in get_plugins @
    if snippet = plugin\get 'scripts: text/html+frag'
      scripts ..= snippet

  scripts

render = (content, fileder, opts={}) ->
  opts.meta or= get_header_tags fileder
  opts.scripts or= ''

  unless opts.noview
    content = [[
      <div class="view main">
        <div class="content">
      ]] .. content .. [[
        </div>
      </div>
    ]]

  buf = [[
<!DOCTYPE html>
<html>
  <head>]]
  buf ..= if STATIC then STATIC.style else [[<link rel="stylesheet" type="text/css" href="/static/style/:text/css" />]]
  buf ..= "
    #{opts.meta}
    #{get_scripts fileder}
  </head>
  <body>
    #{gen_header!}

    #{content}

    #{footer}"
  buf ..= if STATIC then '' else [[
    <script type="text/javascript" src="/static/highlight-pack/:text/javascript"></script>
    <script type="text/javascript">hljs.initHighlighting()</script>]]

  buf ..= opts.scripts
  buf ..= STATIC.scripts if STATIC
  buf ..= "
  </body>
</html>"

  buf

{
  {
    -- inp: 'text/html%+frag',
    -- @TODO: this doesn't feel right... maybe mmm/dom has to go?
    inp: 'mmm/dom',
    out: 'text/html',
    cost: 3
    transform: (html, fileder) => render html, fileder
  },
  {
    inp: 'mmm/dom%+noview',
    out: 'text/html',
    cost: 3
    transform: (html, fileder) => render html, fileder, noview: true
  }
}
