require 'lfs'

get_path = (root) ->
  cwd = lfs.currentdir!
  path = ''

  while root\find '^%.%./'
    root = root\match '^%.%./(.*)'
    cwd, trimmed = cwd\match '(.*)(/[^/]+)$'
    path = trimmed .. path

  path

{
  :get_path
}
