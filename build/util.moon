require 'lfs'
import Fileder, Key from require 'mmm.mmmfs.fileder'

get_path = (root) ->
  cwd = lfs.currentdir!
  path = ''

  while root\find '^%.%./'
    root = root\match '^%.%./(.*)'
    cwd, trimmed = cwd\match '(.*)(/[^/]+)$'
    path = trimmed .. path

  path

-- split filename into dirname + basename
dir_base = (path) ->
  dir, base = path\match '(.-)([^/]-)$'
  if dir and #dir > 0
    dir = dir\sub 1, #dir - 1

  dir, base

load_tree = (store, root='') ->
  fileders = setmetatable {},
    __index: (path) =>
      with val = Fileder {}
        .path = path
        rawset @, path, val

  root = fileders[root]
  root.facets['name: alpha'] = ''
  for fn, ft in store\list_facets root.path
    val = store\load_facet root.path, fn, ft
    root.facets[Key fn, ft] = val

  for path in store\list_all_fileders root.path
    fileder = fileders[path]

    parent, name = dir_base path
    fileder.facets['name: alpha'] = name
    table.insert fileders[parent].children, fileder

    for fn, ft in store\list_facets path
      val = store\load_facet path, fn, ft
      fileder.facets[Key fn, ft] = val

  root

{
  :get_path
  :dir_base
  :load_tree
}
