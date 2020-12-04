require = relative ..., 1
refs = require 'mmm.refs'
import Queue from require '.queue'
import get_plugins from require '.meta'

count = (base, pattern='->') -> select 2, base\gsub pattern, ''
escape_pattern = (inp) ->
  if '*' == inp\sub -1
    inp = inp\sub 1, -2
    "^#{inp\gsub '([^%w])', '%%%1'}"
  else
    "^#{inp\gsub '([^%w])', '%%%1'}$"
escape_inp = (inp) -> "^#{inp\gsub '([-/])', '%%%1'}$"

class MermaidDebugger
  new: =>
    nextid = 0
    @type_id = setmetatable {}, __index: (t, k) ->
      nextid += 1
      with val = "type-#{nextid}"
        t[k] = val

    @cost = {}
    @buf = ""

  prepend: (line) =>
    @buf = "  #{line}\n" .. @buf

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
    @prepend "#{@type_id[frm]} -- cost: #{cost} --> #{@type_id[to]}"

  render: =>
    for type, id in pairs @type_id
      cost = @cost[type] or -1
      @prepend "#{id}[\"#{type} [#{cost}]\"]"

    @append "classDef have fill:#ada"
    @append "classDef want fill:#add"
    @append "classDef cant fill:#daa"

    "graph TD\n" .. @buf

get_converts = (fileder) ->
  assert PLUGINS
  converts = [c for c in *PLUGINS.converts]

  for plugin in get_plugins fileder
    for c in *(plugin\get('converts: table') or {})
      table.insert converts, c

  converts

-- attempt to find a conversion path from 'have' to 'want'
-- * fileder - fileder to start with
-- * have - start type string or list of type strings
-- * want - stop type pattern
-- * limit - limit conversion amount
-- * debug - a table with debug hooks
-- returns a list of conversion steps
get_conversions = (fileder, want, have, converts, limit=5, debug) ->
  converts or= get_converts fileder

  assert have, 'need starting type(s)'
  assert converts, 'need to pass list of converts'

  if 'string' == type have
    have = { have }

  assert #have > 0, 'need starting type(s) (list was empty)'

  want = escape_pattern want
  limit = limit + 3 * math.max table.unpack [count type for type in *have]
  if debug
    debug\found_type want
    debug\type_cost want, limit
    debug\type_class want, 'want'

  had = {}
  queue = Queue!
  for start in *have
    return {}, start if start\match want
    queue\add { :start, rest: start, conversions: {} }, 0, start

    if debug
      debug\found_type start
      debug\type_cost start, 0
      debug\type_class start, 'have'

  best = Queue!

  while true
    entry, cost = queue\pop!
    if not entry
      break

    if cost > limit
      debug\type_class entry.rest, 'cant' if debug
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
        best\add next_entry, next_entry.cost
        debug\found_link result, want, 0 if debug
      else
        queue\add next_entry, next_entry.cost, result

  if solution = best\pop!
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
apply_conversions = (fileder, conversions, value, key) ->
  for i=#conversions,1,-1
    refs\push!
    step = conversions[i]
    ok, value = xpcall step.convert.transform, err_and_trace, step, value, fileder, key
    refs\pop!
    if not ok
      error "error while converting #{fileder} #{key} from '#{step.from}' to '#{step.to}':\n#{value}"

  value

-- find and apply a conversion path from 'have' to 'want'
-- * have - start type string or list of type strings
-- * want - stop type pattern
-- * value - value or map from have-types to values
-- returns converted value
convert = (have, want, value, fileder, key) ->
  conversions, start = get_conversions fileder, want, have

  if not conversions
    warn "couldn't convert from '#{have}' to '#{want}'"
    return

  if 'string' ~= type have
     value = value[start]

  apply_conversions fileder, conversions, value, key

{
  :MermaidDebugger

  :get_conversions
  :apply_conversions
  :convert
}
