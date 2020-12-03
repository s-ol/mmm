require = relative ..., 1
import div, pre, code, img, video, span, source  from require 'mmm.dom'
import find_fileder, link_to, embed from (require 'mmm.mmmfs.util') require 'mmm.dom'
import render from require '.layout'
import tohtml from require 'mmm.component'

-- fix JS null values
js_fix = if MODE == 'CLIENT'
  (arg) ->
    return if arg == js.null
    return if arg == ''
    arg

-- fix JS bool values
js_bool = if MODE == 'CLIENT'
  (arg) ->
    return nil if arg == js.null
    return false if arg == 'false'
    true

-- limit function to one argument
single = (func) -> (val) => func val

-- load a chunk using a specific 'load'er
loadwith = (_load) -> (val, fileder, key) =>
  func = assert _load val, "#{fileder}##{key}"
  func!

string.yieldable_gsub = (str, pat, f) ->
  -- escape percent signs
  str = str\gsub '%%', '%%|'

  matches = {}
  str, cnt = str\gsub pat, (...) ->
    table.insert matches, { ... }
    "%#{#matches}"

  for match in *matches
    match.replacement = f table.unpack match

  str = str\gsub '%%(%d+)', (i) ->
    i = tonumber i
    matches[i].replacement

  -- unescape escaped percent signs
  str = str\gsub '%%|', '%%'
  str, cnt

-- list of converts, editors, scripts
-- converts each have
-- * inp - input type. can capture subtypes using `(.+)`
-- * out - output type. can substitute subtypes from inp with %1, %2 etc.
-- * cost - conversion cost
-- * transform - function (val: inp, fileder) => val: out
--               @convert, @from, @to contain the convert and the concrete types
editors = {}
scripts = ''
converts = {
  {
    inp: 'fn -> (.+)',
    out: '%1',
    cost: 1
    transform: (val, fileder) => val fileder
  }
  {
    inp: 'mmm/component',
    out: 'mmm/dom',
    cost: 3
    transform: single tohtml
  }
  {
    inp: 'mmm/dom',
    out: 'text/html+frag',
    cost: 3
    transform: (node) => if MODE == 'SERVER' then node else node.outerHTML
  }
  {
    -- inp: 'text/html%+frag',
    -- @TODO: this doesn't feel right... maybe mmm/dom has to go?
    inp: 'mmm/dom',
    out: 'text/html',
    cost: 3
    transform: (html, fileder) => render html, fileder
  }
  {
    inp: 'text/html%+frag',
    out: 'mmm/dom',
    cost: 0.1
    transform: if MODE == 'SERVER'
      (html, fileder) =>
        html = html\yieldable_gsub '<mmm%-link%s+(.-)>(.-)</mmm%-link>', (attrs, text) ->
          text = nil if #text == 0
          path = ''
          while attrs and attrs != ''
            key, val, _attrs = attrs\match '^(%w+)="([^"]-)"%s*(.*)'
            if not key
              key, _attrs = attrs\match '^(%w+)%s*(.*)$'
              val = true

            attrs = _attrs

            switch key
              when 'path' then path = val
              else warn "unkown attribute '#{key}=\"#{val}\"' in <mmm-link>"

          link_to path, text, fileder

        html = html\yieldable_gsub '<mmm%-embed%s+(.-)>(.-)</mmm%-embed>', (attrs, desc) ->
          path, facet = '', ''
          opts = {}
          if #desc != 0
            opts.desc = desc

          while attrs and attrs != ''
            key, val, _attrs = attrs\match '^(%w+)="([^"]-)"%s*(.*)'
            if not key
              key, _attrs = attrs\match '^(%w+)%s*(.*)$'
              val = true

            attrs = _attrs

            switch key
              when 'path' then path = val
              when 'facet' then facet = val
              when 'wrap' then opts.wrap = val
              when 'style' then opts.style = val
              when 'nolink' then opts.nolink = true
              when 'inline' then opts.inline = true

              when 'raw' then opts.raw = true -- deprecated

              else warn "unkown attribute '#{key}=\"#{val}\"' in <mmm-embed>"

          embed path, facet, fileder, opts

        html
    else
      (html, fileder) =>
        parent = with document\createElement 'div'
          .innerHTML = html

          -- copy to iterate safely, HTMLCollections update when nodes are GC'ed
          embeds = \getElementsByTagName 'mmm-embed'
          embeds = [embeds[i] for i=0, embeds.length - 1]
          for element in *embeds
            path = js_fix element\getAttribute 'path'
            facet = js_fix element\getAttribute 'facet'
            wrap = js_fix element\getAttribute 'wrap'
            style = js_fix element\getAttribute 'style'
            nolink = js_bool element\getAttribute 'nolink'
            inline = js_bool element\getAttribute 'inline'
            desc = js_fix element.innerText
            desc = nil if desc == ''

            raw = js_bool element\getAttribute 'raw' -- deprecated

            opts = :wrap, :style, :nolink, :inline, :desc, :raw
            element\replaceWith embed path or '', facet or '', fileder, opts

          embeds = \getElementsByTagName 'mmm-link'
          embeds = [embeds[i] for i=0, embeds.length - 1]
          for element in *embeds
            text = js_fix element.innerText
            path = js_fix element\getAttribute 'path'

            element\replaceWith link_to path or '', text, fileder

        assert 1 == parent.childElementCount, "text/html with more than one child!"
        parent.firstElementChild
  }
  {
    inp: 'mmm/tpl -> (.+)',
    out: '%1',
    cost: 1
    transform: (source, fileder) =>
      source\yieldable_gsub '{{(.-)}}', (expr) ->
        path, facet = expr\match '^([%w%-_%./]*)%+(.*)'
        assert path, "couldn't match TPL expression '#{expr}'"

        (find_fileder path, fileder)\gett facet
  }
  {
    inp: 'time/iso8601-date',
    out: 'time/unix',
    cost: 0.5
    transform: (val) =>
      year, _, month, day = val\match '^%s*(%d%d%d%d)(%-?)([01]%d)%2([0-3]%d)%s*$'
      assert year, "failed to parse ISO 8601 date: '#{val}'"
      os.time :year, :month, :day
  }
  {
    inp: 'URL -> image/.+',
    out: 'mmm/dom',
    cost: -4
    transform: (src, fileder) => img :src
  }
  {
    inp: 'URL -> video/.+%+gif',
    out: 'mmm/dom',
    cost: -4.01
    transform: (src) =>
      video (source :src), controls: 'auto', loop: true, autoplay: true, muted: true
  }
  {
    inp: 'URL -> video/.+',
    out: 'mmm/dom',
    cost: -4
    transform: (src) =>
      -- @TODO: add parsed MIME type
      video (source :src), controls: true, loop: true
  }
  {
    inp: 'text/plain',
    out: 'mmm/dom',
    cost: 2
    transform: (val) => span val
  }
  {
    inp: 'alpha',
    out: 'mmm/dom',
    cost: 2
    transform: single code
  }
  {
    inp: 'URL -> (.+)',
    out: '%1',
    cost: 4,
    transform: do
      if MODE == 'CLIENT'
        (uri) =>
          request = js.new js.global.XMLHttpRequest
          request\open 'GET', uri, false
          request\send js.null

          assert request.status == 200, "unexpected status code: #{request.status}"
          request.responseText
      else
        (uri) =>
          request = require 'http.request'
          req = request.new_from_uri uri
          req.headers\upsert 'origin', 'null'
          headers, stream = assert req\go 8
          assert stream\get_body_as_string!
  }
  {
    inp: 'table',
    out: 'mmm/dom',
    cost: 5
    transform: do
      deep_tostring = (tbl, space='') ->
        buf = space .. tostring tbl

        return buf unless 'table' == type tbl

        buf = buf .. ' {\n'
        for k,v in pairs tbl
          buf = buf .. "#{space} [#{k}]: #{deep_tostring v, space .. '  '}\n"
        buf = buf .. "#{space}}"
        buf

      (tbl) => pre code deep_tostring tbl
  }
}

if MODE == 'CLIENT' or UNSAFE
  table.insert converts, {
    inp: 'text/lua -> (.+)',
    out: '%1',
    cost: 0.5
    transform: loadwith load or loadstring
  }

add_plugin = (module) ->
  ok, plugin = pcall require, ".plugins.#{module}"

  if not ok
    print "[Plugins] couldn't load plugins.#{module}: #{plugin}"
    return

  print "[Plugins] loaded plugins.#{module}"

  if plugin.converts
    for convert in *plugin.converts
      table.insert converts, convert

  if plugin.editors
    for editor in *plugin.editors
      table.insert editors, editor

  if plugin.scripts
    scripts ..= plugin.scripts

add_plugin 'code'
add_plugin 'markdown'
add_plugin 'mermaid'
add_plugin 'gltf'

if not STATIC
  table.insert converts, {
    inp: '(.+)',
    out: 'URL -> %1',
    cost: 5
    transform: (_, fileder, key) => "#{fileder.path}/#{key.name}:#{@from}"
  }

if MODE == 'SERVER'
  ok, moon = pcall require, 'moonscript.base'
  if ok
    _load = moon.load or moon.loadstring
    if UNSAFE
      table.insert converts, {
        inp: 'text/moonscript -> (.+)',
        out: '%1',
        cost: 1
        transform: loadwith moon.load or moon.loadstring
      }

    table.insert converts, {
      inp: 'text/moonscript -> (.+)',
      out: 'text/lua -> %1',
      cost: 2
      transform: single moon.to_lua
    }
else
  table.insert converts, {
    inp: 'text/javascript -> (.+)',
    out: '%1',
    cost: 1
    transform: (source) =>
      f = js.new window.Function, source
      f!
  }

{
  :converts
  :editors
  :scripts
}
