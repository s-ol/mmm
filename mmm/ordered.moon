-- ordered table iterator, for stable(r) renderers

sort = (t, order_fn, only_strings) ->
  with index = [k for k,v in pairs t when (not only_strings) or 'string' == type k]
    table.sort index, order_fn

-- ordered next(t)
onext = (state, key) ->
  state.i += state.step
  { :t, :index, :i } = state

  if key = index[i]
    key, t[key]

-- ordered pairs(t).
-- order_fn is optional; see table.sort
opairs = (t, order_fn, only_strings=false) ->
  state = {
    :t
    i: 0
    step: 1
    index: sort t, order_fn, only_strings
  }
  onext, state, nil

-- reverse opairs(...)
ropairs = (t, order_fn, only_strings=false) ->
  index = sort t, order_fn, only_strings
  state = {
    :t
    :index
    i: #index + 1
    step: -1
  }
  onext, state, nil

{
  :onext
  :opairs
  :ropairs
}
