import Fileder from require 'mmm.mmmfs.fileder'
require 'lfs'

readfile = (name) ->
  file = io.open name, 'r'
  with file\read '*all'
    file\close!

-- load a fs file as a fileder property
load_property = (path, filename) ->
  key = (filename\match '(.*)%.%w+') or filename
  key = key\gsub '%$', '/'

  value = readfile path .. filename

  key, value

-- load a fs directory as a fileder
load_fileder = (path='root/', name='') ->
  path = path .. name
  path ..= '/' unless '/' == path\sub -1

  with Fileder 'name: alpha': name
    for entry in lfs.dir path
      continue if entry == '.' or entry == '..'
      continue if entry == 'init.moon'

      attr = lfs.attributes path .. entry
      switch attr.mode
        when 'file'
          key, value = load_property path, entry
          .props[key] = value
        when 'directory'
          table.insert .children, load_fileder path, entry
        else
          error "unknown file type: #{attr.mode}"

{
  :load_property
  :load_fileder
}
