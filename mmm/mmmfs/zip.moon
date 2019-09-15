require = relative ..., 1
import Fileder, Key from require '.fileder'
zip = require 'brimworks.zip'

-- split filename into dirname + basename
dir_base = (path) ->
  dir, base = path\match '(.-)([^/]-)$'
  if dir and #dir > 0
    dir = dir\sub 1, #dir - 1

  dir, base

-- insert into array unless contained
table_add = (tbl, entry) ->
  for _, v in ipairs tbl
    if v == entry
      return

  table.insert tbl, entry

-- strip facet formatting
load_facet = (filename) ->
  key = (filename\match '(.*)%.%w+') or filename
  key = Key key\gsub '%$', '/'
  key.filename = filename

  key

load_tree = (file='root.zip') ->
  archive = zip.open file

  fileders = setmetatable {},
    __index: (path) =>
      with val = Fileder {}
        .path = path
        rawset @, path, val

  fileders['/root'].facets['name: alpha'] = -> 'root'

  for i = 1, #archive
    { :name, :size } = archive\stat i

    path, facet = dir_base "/#{name}"
    parent, name = dir_base path

    key = load_facet facet

    this = fileders[path]
    this.facets['name: alpha'] = -> name
    this.facets[key] = ->
      file = archive\open i
      with file\read size
        file\close!

    table_add fileders[parent].children, this

  fileders['/root']

{ :load_tree }
