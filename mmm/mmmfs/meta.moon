-- like Fileder:walk but yield all ancestors of path
-- * path - the path to walk to
yield_ancestors = do
  step = (path) =>
    path = "#{@path}/#{path}" if '/' != path\sub 1, 1

    return unless @path == path\sub 1, #@path
    return if #path == #@path

    coroutine.yield @

    for child in *@children
      step child, path

  (path) => coroutine.wrap -> step @, path

get_meta = (fileder, path) ->
  if path
    path = "$mmm/#{path}"
  else
    path = '$mmm'

  local guard_self
  max_path = fileder.path
  if closest = max_path\match '(.-)/$mmm'
    max_path = closest
    guard_self = true

  assert fileder.root, "'#{fileder}' has no root!"

  coroutine.wrap ->
    -- search until closest non-meta ancestor
    for ancestor in yield_ancestors fileder.root, max_path
      break if guard_self and ancestor.path == max_path

      if result = ancestor\walk path
        coroutine.yield result

    if result = not guard_self and fileder\walk path
      coroutine.yield result

get_plugins = (fileder) ->
  coroutine.wrap ->
    for plugins in get_meta fileder, 'plugins'
      for plugin in *plugins.children
        coroutine.yield plugin

{
  :get_meta
  :get_plugins
}
