import div, text, code, img, video, blockquote, a, source, iframe from require 'mmm.dom'
import find_fileder, embed from (require 'mmm.mmmfs.util') require 'mmm.dom'
import tohtml from require 'mmm.component'

-- fix JS null values
js_fix = if MODE == 'CLIENT'
  (arg) ->
    return if arg == js.null
    arg

-- limit function to one argument
single = (func) -> (val) -> func val

-- load a chunk using a specific 'load'er
loadwith = (_load) -> (val, fileder, key) ->
  func = assert _load val, "#{fileder}##{key}"
  func!

-- list of converts
-- converts each have
-- * inp - input type. can capture subtypes using `(.+)`
-- * out - output type. can substitute subtypes from inp with %1, %2 etc.
-- * transform - function (val: inp, fileder) -> val: out
converts = {
  {
    inp: 'fn -> (.+)',
    out: '%1',
    transform: (val, fileder) -> val fileder
  },
  {
    inp: 'mmm/component',
    out: 'mmm/dom',
    transform: single tohtml
  },
  {
    inp: 'mmm/dom',
    out: 'text/html',
    transform: (node) -> if MODE == 'SERVER' then node else node.outerHTML
  },
  {
    inp: 'text/html',
    out: 'mmm/dom',
    transform: if MODE == 'SERVER'
      (html, fileder) ->
        div html\gsub '<mmm%-embed%s+(.-)></mmm%-embed>', (attrs) ->
          path, facet = '', ''
          opts = {}
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
              else warn "unkown attribute '#{key}=\"#{val}\"' in <mmm-embed>"

          embed path, facet, fileder, opts
    else
      (html, fileder) ->
        with document\createElement 'div'
          .innerHTML = html

          -- copy to iterate safely, HTMLCollections update when nodes are GC'ed
          embeds = \getElementsByTagName 'mmm-embed'
          embeds = [embeds[i] for i=0, embeds.length - 1]
          for element in *embeds
            path = js_fix element\getAttribute 'path'
            facet = js_fix element\getAttribute 'facet'
            nolink = js_fix element\getAttribute 'nolink'

            element\replaceWith embed path, facet, fileder, { :nolink }
  },
  {
    inp: 'text/lua -> (.+)',
    out: '%1',
    transform: loadwith load or loadstring
  },
  {
    inp: 'mmm/tpl -> (.+)',
    out: '%1',
    transform: (source, fileder) ->
      source\gsub '{{(.-)}}', (expr) ->
        path, facet = expr\match '^([%w%-_%./]*)%+(.*)'
        assert path, "couldn't match TPL expression '#{expr}'"

        (find_fileder path, fileder)\gett facet
  },
  {
    inp: 'time/iso8601-date',
    out: 'time/unix',
    transform: (val) ->
      year, _, month, day = val\match '^%s*(%d%d%d%d)(%-?)([01]%d)%2([0-3]%d)%s*$'
      assert year, "failed to parse ISO 8601 date: '#{val}'"
      os.time :year, :month, :day
  },
  {
    inp: 'URL -> twitter/tweet',
    out: 'mmm/dom',
    transform: (href) ->
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
  },
  {
    inp: 'URL -> youtube/video',
    out: 'mmm/dom',
    transform: (link) ->
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
        src: "//www.youtube.com/embed/#{id}"
      }
  },
  {
    inp: 'URL -> image/.+',
    out: 'mmm/dom',
    transform: (src, fileder) -> img :src
  },
  {
    inp: 'URL -> video/.+',
    out: 'mmm/dom',
    transform: (src) ->
      -- @TODO: add parsed MIME type
      video (source :src), controls: true
  },
  {
    inp: 'text/plain',
    out: 'mmm/dom',
    transform: single text
  },
  {
    inp: 'alpha',
    out: 'mmm/dom',
    transform: single code
  },
  {
    inp: 'URL -> .*',
    out: 'mmm/dom',
    transform: single code
  },
}

if MODE == 'SERVER'
  ok, moon = pcall require, 'moonscript.base'
  if ok
    _load = moon.load or moon.loadstring
    table.insert converts, {
      inp: 'text/moonscript -> (.+)',
      out: '%1',
      transform: loadwith moon.load or moon.loadstring
    }

    table.insert converts, {
      inp: 'text/moonscript -> (.+)',
      out: 'text/lua -> %1',
      transform: single moon.to_lua
    }
else
  table.insert converts, {
    inp: 'text/javascript -> (.+)',
    out: '%1',
    transform: (source) ->
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
      res, err = discount.compile md, 'githubtags'
      res.body
  else
    markdown = window and window.marked and window\marked

  if markdown
    table.insert converts, {
      inp: 'text/markdown',
      out: 'text/html',
      transform: single markdown
    }

    table.insert converts, {
      inp: 'text/markdown%+span',
      out: 'mmm/dom',
      transform: if MODE == 'SERVER'
        (source) ->
          html = markdown source
          html = html\gsub '^<p', '<span'
          html\gsub '/p>$', '/span>'
      else
        (source) ->
          html = markdown source
          html = html\gsub '^%s*<p>%s*', ''
          html = html\gsub '%s*</p>%s*$', ''
          with document\createElement 'span'
            .innerHTML = html
    }

count = (base, pattern='->') -> select 2, base\gsub pattern, ''
escape_pattern = (inp) -> "^#{inp\gsub '([-/])', '%%%1'}$"

-- attempt to find a conversion path from 'have' to 'want'
-- * have - start type string or list of type strings
-- * want - stop type pattern
-- * limit - limit conversion amount
-- returns a list of conversion steps
get_conversions = (want, have, _converts=converts, limit=3) ->
  assert have, 'need starting type(s)'

  if 'string' == type have
    have = { have }

  assert #have > 0, 'need starting type(s) (list was empty)'

  want = escape_pattern want
  iterations = limit + math.max table.unpack [count type for type in *have]
  have = [{ :start, rest: start, conversions: {} } for start in *have]

  for i=1, iterations
    next_have, c = {}, 1
    for { :start, :rest, :conversions } in *have
      if rest\match want
        return conversions, start
      else
        for convert in *_converts
          inp = escape_pattern convert.inp
          continue unless rest\match inp
          result = rest\gsub inp, convert.out
          if result
            next_have[c] = {
              :start,
              rest: result,
              conversions: { convert, table.unpack conversions }
            }
            c += 1

    have = next_have
    return unless #have > 0

-- apply transforms for conversion path sequentially
-- * conversions - conversions from get_conversions
-- * value - value
-- * ... - other transform parameters (fileder, key)
-- returns converted value
apply_conversions = (conversions, value, ...) ->
  for i=#conversions,1,-1
    { :inp, :out, :transform } = conversions[i]
    value = transform value, ...

  value

{
  :converts
  :get_conversions
  :apply_conversions
}
