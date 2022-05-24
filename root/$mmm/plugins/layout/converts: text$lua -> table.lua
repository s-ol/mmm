local header, aside, footer, div, svg, script, g, circle, h1, span, b, a, img
do
  local _obj_0 = require('mmm.dom')
  header, aside, footer, div, svg, script, g, circle, h1, span, b, a, img = _obj_0.header, _obj_0.aside, _obj_0.footer, _obj_0.div, _obj_0.svg, _obj_0.script, _obj_0.g, _obj_0.circle, _obj_0.h1, _obj_0.span, _obj_0.b, _obj_0.a, _obj_0.img
end
local navigate_to
navigate_to = (require('mmm.mmmfs.util'))(require('mmm.dom')).navigate_to
local get_plugins
get_plugins = require('mmm.mmmfs.meta').get_plugins
local pick
pick = function(...)
  local num = select('#', ...)
  local i = math.ceil(math.random() * num)
  return (select(i, ...))
end
local iconlink
iconlink = function(href, src, alt, style)
  return a({
    class = 'iconlink',
    target = '_blank',
    rel = 'me',
    href = href,
    img({
      src = src,
      alt = alt,
      style = style
    })
  })
end
local logo = svg({
  class = 'sun',
  viewBox = '-0.75 -1 1.5 2',
  xmlns = 'http://www.w3.org/2000/svg',
  baseProfile = 'full',
  version = '1.1',
  g({
    transform = 'translate(0 .18)',
    g({
      class = 'circle out',
      circle({
        r = '.6',
        fill = 'none',
        ['stroke-width'] = '.12'
      })
    }),
    g({
      class = 'circle  in',
      circle({
        r = '.2',
        stroke = 'none'
      })
    })
  })
})
local gen_header
gen_header = function()
  return header({
    div({
      h1({
        navigate_to('', logo),
        span({
          span('mmmfs', {
            class = 'bold'
          }),
          '&#8203;',
          '.s&#8209;ol.nu'
        })
      }),
      "a hypermedia information system."
    })
  })
end
footer = footer({
  span({
    'made with \xe2\x98\xbd by ',
    a('s-ol', {
      href = 'https://s-ol.nu'
    }),
    ", " .. tostring(os.date('%Y'))
  }),
  div({
    class = 'icons',
    iconlink('https://github.com/s-ol', 'https://cdn.jsdelivr.net/npm/simple-icons@latest/icons/github.svg', 'github'),
    iconlink('https://merveilles.town/@s_ol', 'https://cdn.jsdelivr.net/npm/simple-icons@latest/icons/mastodon.svg', 'mastodon'),
    iconlink('https://twitter.com/S0lll0s', 'https://cdn.jsdelivr.net/npm/simple-icons@latest/icons/twitter.svg', 'twitter'),
    iconlink('https://webring.xxiivv.com/#random', 'https://webring.xxiivv.com/icon.black.svg', 'webring', {
      height = '1.3em',
      ['margin-left'] = '.3em',
      ['margin-top'] = '-0.12em'
    })
  })
})
local get_header_tags
get_header_tags = function(self)
  local title = (self:get('title: text/plain')) or self:gett('name: alpha')
  local l
  l = function(str)
    str = str:gsub('[%s\n]+$', '')
    return str:gsub('\n', ' ')
  end
  local e
  e = function(str)
    return string.format('%q', l(str))
  end
  local meta = "\n    <meta charset=\"UTF-8\">\n    <title>" .. tostring(l(title)) .. "</title>\n  "
  do
    local page_meta = self:get('_meta: mmm/dom')
    if page_meta then
      meta = meta .. page_meta
    else
      meta = meta .. "\n    <meta name=\"viewport\" content=\"width=device-width, initial-scale=1\">\n\n    <meta property=\"og:title\" content=" .. tostring(e(title)) .. " />\n    <meta property=\"og:type\"  content=\"website\" />\n    <meta property=\"og:url\"   content=\"https://mmm.s-ol.nu" .. tostring(self.path) .. "/\" />\n    <meta property=\"og:site_name\" content=\"mmm\" />"
      do
        local desc = self:get('description: text/plain')
        if desc then
          meta = meta .. "\n    <meta property=\"og:description\" content=" .. tostring(e(desc)) .. " />"
        end
      end
    end
  end
  return meta
end
local get_scripts
get_scripts = function(self)
  local scripts = ''
  for plugin in get_plugins(self) do
    do
      local snippet = plugin:get('scripts: text/html+frag')
      if snippet then
        scripts = scripts .. snippet
      end
    end
  end
  return scripts
end
local render
render = function(content, fileder, opts)
  if opts == nil then
    opts = { }
  end
  opts.meta = opts.meta or get_header_tags(fileder)
  opts.scripts = opts.scripts or ''
  if not (opts.noview) then
    content = [[      <div class="view main">
        <div class="content">
      ]] .. content .. [[        </div>
      </div>
    ]]
  end
  local buf = [[<!DOCTYPE html>
<html>
  <head>]]
  buf = buf .. (function()
    if STATIC then
      return STATIC.style
    else
      return [[<link rel="stylesheet" type="text/css" href="/static/style/:text/css" />]]
    end
  end)()
  buf = buf .. "\n    " .. tostring(opts.meta) .. "\n    " .. tostring(get_scripts(fileder)) .. "\n  </head>\n  <body>\n    " .. tostring(gen_header()) .. "\n\n    " .. tostring(content) .. "\n\n    " .. tostring(footer)
  buf = buf .. (function()
    if STATIC then
      return ''
    else
      return [[    <script type="text/javascript" src="/static/highlight-pack/:text/javascript"></script>
    <script type="text/javascript">hljs.initHighlighting()</script>]]
    end
  end)()
  buf = buf .. opts.scripts
  if STATIC then
    buf = buf .. STATIC.scripts
  end
  buf = buf .. "\n  </body>\n</html>"
  return buf
end
return {
  {
    inp = 'mmm/dom',
    out = 'text/html',
    cost = 3,
    transform = function(self, html, fileder)
      return render(html, fileder)
    end
  },
  {
    inp = 'mmm/dom%+noview',
    out = 'text/html',
    cost = 3,
    transform = function(self, html, fileder)
      return render(html, fileder, {
        noview = true
      })
    end
  }
}
