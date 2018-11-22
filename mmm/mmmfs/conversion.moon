import div, text, code from require 'mmm.dom'
import tohtml from require 'mmm.component'

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
      (html) -> div html
    else
      (html) ->
        with document\createElement 'div'
          .innerHTML = html
  },
  {
    inp: 'text/lua -> (.+)',
    out: '%1',
    transform: loadwith load or loadstring
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
    markdown = discount if success
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
          html = html\gsub '^<p>', ''
          html = html\gsub '</p>$', ''
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
