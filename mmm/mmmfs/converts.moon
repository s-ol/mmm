require = relative ..., 1
import div, pre, code, img, video, blockquote, a, span, source, iframe from require 'mmm.dom'
import find_fileder, link_to, embed from (require 'mmm.mmmfs.util') require 'mmm.dom'
import render from require '.layout'
import tohtml from require 'mmm.component'
import languages from require 'mmm.highlighting'

keep = (var) ->
  last = var\get!
  var\map (val) ->
    last = val or last
    last

-- fix JS null values
js_fix = if MODE == 'CLIENT'
  (arg) ->
    return if arg == js.null
    arg

-- limit function to one argument
single = (func) -> (val) => func val

-- load a chunk using a specific 'load'er
loadwith = (_load) -> (val, fileder, key) =>
  func = assert _load val, "#{fileder}##{key}"
  func!

-- highlight code
code_hl = (lang) ->
  {
    inp: "text/#{lang}",
    out: 'mmm/dom',
    cost: 5
    transform: (val) => pre languages[lang] val
  }

-- list of converts
-- converts each have
-- * inp - input type. can capture subtypes using `(.+)`
-- * out - output type. can substitute subtypes from inp with %1, %2 etc.
-- * transform - function (val: inp, fileder) -> val: out
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
    cost: 1
    transform: if MODE == 'SERVER'
      (html, fileder) =>
        html = html\gsub '<mmm%-link%s+(.-)>(.-)</mmm%-link>', (attrs, text) ->
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

        html = html\gsub '<mmm%-embed%s+(.-)>(.-)</mmm%-embed>', (attrs, desc) ->
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
              when 'nolink' then opts.nolink = true
              when 'inline' then opts.inline = true
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
            nolink = js_fix element\getAttribute 'nolink'
            inline = js_fix element\getAttribute 'inline'
            desc = js_fix element.innerText
            desc = nil if desc == ''

            element\replaceWith embed path or '', facet or '', fileder, { :nolink, :inline, :desc }

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
    inp: 'text/lua -> (.+)',
    out: '%1',
    cost: 0.5
    transform: loadwith load or loadstring
  }
  {
    inp: 'mmm/tpl -> (.+)',
    out: '%1',
    cost: 1
    transform: (source, fileder) =>
      source\gsub '{{(.-)}}', (expr) ->
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
    inp: 'URL -> twitter/tweet',
    out: 'mmm/dom',
    cost: 1
    transform: (href) =>
      id = assert (href\match 'twitter.com/[^/]-/status/(%d*)'), "couldn't parse twitter/tweet URL: '#{href}'"
      if MODE == 'CLIENT'
        with parent = div!
          window.twttr.widgets\createTweet id, parent
      else
        div blockquote {
          class: 'twitter-tweet'
          'data-lang': 'en'
          a '(linked tweet)', :href
        }
  }
  {
    inp: 'URL -> youtube/video',
    out: 'mmm/dom',
    cost: 1
    transform: (link) =>
      id = link\match 'youtu%.be/([^/]+)'
      id or= link\match 'youtube.com/watch.*[?&]v=([^&]+)'
      id or= link\match 'youtube.com/[ev]/([^/]+)'
      id or= link\match 'youtube.com/embed/([^/]+)'

      assert id, "couldn't parse youtube URL: '#{link}'"

      iframe {
        width: 560
        height: 315
        frameborder: 0
        allowfullscreen: true
        frameBorder: 0
        src: "//www.youtube.com/embed/#{id}"
      }
  }
  {
    inp: 'URL -> image/.+',
    out: 'mmm/dom',
    cost: 1
    transform: (src, fileder) => img :src
  }
  {
    inp: 'URL -> video/.+',
    out: 'mmm/dom',
    cost: 1
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
  -- this one needs a higher cost
  -- {
  --   inp: 'URL -> .+',
  --   out: 'mmm/dom',
  --   transform: single code
  -- }
  {
    inp: '(.+)',
    out: 'URL -> %1',
    cost: 5
    transform: (_, fileder, key) => "#{fileder.path}/#{key.name}:#{@from}"
  }
  {
    inp: 'table',
    out: 'text/json',
    cost: 2
    transform: do
      tojson = (obj) ->
        switch type obj
          when 'string'
            string.format '%q', obj
          when 'table'
            if obj[1] or not next obj
              "[#{table.concat [tojson c for c in *obj], ','}]"
            else
              "{#{table.concat ["#{tojson k}: #{tojson v}" for k,v in pairs obj], ', '}}"
          when 'number'
            tostring obj
          when 'boolean'
            tostring obj
          when 'nil'
            'null'
          else
            error "unknown type '#{type obj}'"

      (val) => tojson val
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
  code_hl 'javascript'
  code_hl 'moonscript'
  code_hl 'lua'
  code_hl 'markdown'
  code_hl 'css'
}

if MODE == 'SERVER'
  ok, moon = pcall require, 'moonscript.base'
  if ok
    _load = moon.load or moon.loadstring
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

do
  local markdown
  if MODE == 'SERVER'
    success, discount = pcall require, 'discount'
    if not success
      warn "NO MARKDOWN SUPPORT!", discount

    markdown = success and (md) ->
      res = assert discount.compile md, 'githubtags'
      res.body
  else
    markdown = window and window.marked and window\marked

  if markdown
    table.insert converts, {
      inp: 'text/markdown',
      out: 'text/html+frag',
      cost: 1
      transform: (md) => "<div class=\"markdown\">#{markdown md}</div>"
    }

    table.insert converts, {
      inp: 'text/markdown%+span',
      out: 'mmm/dom',
      cost: 1
      transform: if MODE == 'SERVER'
        (source) =>
          html = markdown source
          html = html\gsub '^<p', '<span'
          html\gsub '/p>$', '/span>'
      else
        (source) =>
          html = markdown source
          html = html\gsub '^%s*<p>%s*', ''
          html = html\gsub '%s*</p>%s*$', ''
          with document\createElement 'span'
            .innerHTML = html
    }

if MODE == 'CLIENT' and window.mermaid
  window.mermaid\initialize {
    startOnLoad: false
    fontFamily: 'monospace'
   }
  
  id_counter = 1
  table.insert converts, {
    inp: 'text/mermaid-graph'
    out: 'mmm/dom'
    cost: 1
    transform: (source, fileder, key) =>
      id_counter += 1
      id = "mermaid-#{id_counter}"
      with container = document\createElement 'div'
        cb = (svg) =>
          .innerHTML = svg
        window\setImmediate (_) ->
          window.mermaid\render id, source, cb, container
  }

converts
