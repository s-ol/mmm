require = relative ..., 1
base_converts = require '.converts'
import Queue from require '.queue'

count = (base, pattern='->') -> select 2, base\gsub pattern, ''
escape_pattern = (inp) -> "^#{inp\gsub '([^%w])', '%%%1'}$"
escape_inp = (inp) -> "^#{inp\gsub '([-/])', '%%%1'}$"

local print_conversions

-- attempt to find a conversion path from 'have' to 'want'
-- * have - start type string or list of type strings
-- * want - stop type pattern
-- * limit - limit conversion amount
-- returns a list of conversion steps
get_conversions = (want, have, converts=base_converts, limit=5) ->
  assert have, 'need starting type(s)'

  if 'string' == type have
    have = { have }

  assert #have > 0, 'need starting type(s) (list was empty)'

  want = escape_pattern want
  limit = limit + 3 * math.max table.unpack [count type for type in *have]

  had = {}
  queue = Queue!
  for start in *have
    return {}, start if want\match start
    queue\add { :start, rest: start, conversions: {} }, 0, start

  best = Queue!

  while true
    entry, cost = queue\pop!
    if not entry or cost > limit
      break

    { :start, :rest, :conversions } = entry
    had[rest] = true
    for convert in *converts
      inp = escape_inp convert.inp
      continue unless rest\match inp
      result = rest\gsub inp, convert.out
      continue unless result
      continue if had[result]

      next_entry = {
        :start
        rest: result
        cost: cost + convert.cost
        conversions: { { :convert, from: rest, to: result }, table.unpack conversions }
      }

      if result\match want
        best\add next_entry, next_entry.cost
      else
        queue\add next_entry, next_entry.cost, result


  if solution = best\pop!
    -- print "BEST: (#{solution.cost})"
    -- print_conversions solution.conversions
    solution.conversions, solution.start if solution

-- stringify conversions for debugging
-- * conversions - conversions from get_conversions
print_conversions = (conversions) ->
  print "converting:"
  for i=#conversions,1,-1
    step = conversions[i]
    print "- #{step.from} -> #{step.to} (#{step.convert.cost})"

-- apply transforms for conversion path sequentially
-- * conversions - conversions from get_conversions
-- * value - value
-- * ... - other transform parameters (fileder, key)
-- returns converted value
err_and_trace = (msg) -> debug.traceback msg, 2
apply_conversions = (conversions, value, ...) ->
  for i=#conversions,1,-1
    step = conversions[i]
    ok, value = xpcall step.convert.transform, err_and_trace, step, value, ...
    if not ok
      f, k = ...
      error "error while converting #{f} #{k} from '#{step.from}' to '#{step.to}':\n#{value}"

  value

-- find and apply a conversion path from 'have' to 'want'
-- * have - start type string or list of type strings
-- * want - stop type pattern
-- * value - value or map from have-types to values
-- returns converted value
convert = (have, want, value, ...) ->
  conversions, start = get_conversions want, have

  if not conversions
    warn "couldn't convert from '#{have}' to '#{want}'"
    return

  if 'string' ~= type have
     value = value[start]

  apply_conversions conversions, value, ...

{
  :get_conversions
  :apply_conversions
  :convert
}
