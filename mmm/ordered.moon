-- ordered table iterator, for stable(r) renderers

sort = (t, order_fn, only_strings) ->
  with index = [k for k,v in pairs t when (not only_strings) or 'string' == type k]
    table.sort index, order_fn

-- ordered next(t)
onext = (state, key) ->
  state.i += 1
  { :t, :index, :i } = state

  if key = index[i]
    key, t[key]

-- ordered pairs(t).
-- order_fn is optional; see table.sort
opairs = (t, order_fn, only_strings=false) ->
  state = {
    :t,
    i: 0,
    index: sort t, order_fn, only_strings
  }
  onext, state, nil

{
  :onext
  :opairs
}
