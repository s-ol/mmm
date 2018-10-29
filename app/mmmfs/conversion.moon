import text, code from require 'lib.dom'
import tohtml from require 'lib.component'

-- limit function to one argument
single = (func) -> (val) -> func val

-- list of converts
-- converts each have
-- * inp - input type. can capture subtypes using `(.+)`
-- * out - output type. can substitute subtypes from inp with %1, %2 etc.
-- * transform - function (val: inp, fileder) -> val: out
converts = {
  {
    inp: 'moon -> (.+)',
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
      (...) -> ...
    else
      (html) ->
        tmp = document\createElement 'div'
        tmp.innerHTML = html
        if tmp.childElementCount == 1
          tmp.firstChild
        else
          tmp
  }
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
      transform: (val) ->
        html = markdown val
        warn html
        html
    }

count = (base, pattern='->') -> select 2, base\gsub pattern, ''
escape_inp = (inp) -> "^#{inp\gsub '([-/])', '%%%1'}$"

-- attempt to find a conversion path from 'have' to 'want'
-- * have - start type string or list of type strings
-- * want - stop type string
-- * limit - limit conversion amount
-- returns a list of conversion steps
get_conversions = (want, have, limit=3) ->
  assert have, 'need starting type(s)'

  if 'string' == type have
    have = { have }

  assert #have > 0, 'need starting type(s) (list was empty)'

  iterations = limit + math.max table.unpack [count type for type in *have]
  have = [{ :start, rest: start, conversions: {} } for start in *have]

  for i=1, iterations
    next_have, c = {}, 1
    for { :start, :rest, :conversions } in *have
      if want == rest
        return conversions, start
      else
        for convert in *converts
          inp = escape_inp convert.inp
          matches = { rest\match inp }
          continue unless #matches > 0
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

{
  :converts
  :get_conversions
}
