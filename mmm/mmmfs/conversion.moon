require = relative ..., 1
converts = require '.converts'

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
