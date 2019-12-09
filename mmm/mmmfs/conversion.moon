require = relative ..., 1
import Queue from require '.queue'

count = (base, pattern='->') -> select 2, base\gsub pattern, ''
escape_pattern = (inp) -> "^#{inp\gsub '([^%w])', '%%%1'}$"
escape_inp = (inp) -> "^#{inp\gsub '([-/])', '%%%1'}$"

local print_conversions

class MermaidDebugger
  new: =>
    nextid = 0
    @type_id = setmetatable {}, __index: (t, k) ->
      nextid += 1
      with val = "type-#{nextid}"
        t[k] = val

    @cost = {}
    @buf = "graph TD\n"

  append: (line) =>
    @buf ..= "  #{line}\n"

  found_type: (type) =>
    type_id = @type_id[type]

  type_cost: (type, cost) =>
    if old_cost = @cost[type]
      cost = math.min old_cost, cost
    @cost[type] = cost

  type_class: (type, klass) =>
    @append "class #{@type_id[type]} #{klass}"

  found_link: (frm, to, cost) =>
    @append "#{@type_id[frm]} -- cost: #{cost} --> #{@type_id[to]}"

  render: =>
    for type, id in pairs @type_id
      cost = @cost[type] or -1
      @append "#{id}[\"#{type} [#{cost}]\"]"

    @append "classDef have fill:#ada"
    @append "classDef want fill:#add"

    @buf

-- attempt to find a conversion path from 'have' to 'want'
-- * have - start type string or list of type strings
-- * want - stop type pattern
-- * limit - limit conversion amount
-- * debug - a table with debug hooks
-- returns a list of conversion steps
get_conversions = (want, have, converts=PLUGINS and PLUGINS.converts, limit=5, debug) ->
  assert have, 'need starting type(s)'
  assert converts,  'need to pass list of converts'

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

    if debug
      debug\found_type start
      debug\type_cost start, 0
      debug\type_class start, 'have'

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

      if debug
        debug\found_type result
        debug\type_cost result, next_entry.cost
        debug\found_link rest, result, convert.cost

      if result\match want
        debug\type_class result, 'want' if debug
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
err_and_trace = (msg) -> debug.traceback msg, 1
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
  :MermaidDebugger

  :get_conversions
  :apply_conversions
  :convert
}
