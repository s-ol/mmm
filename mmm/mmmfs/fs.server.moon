import Fileder from require 'mmm.mmmfs.fileder'
import opairs from require 'mmm.ordered'
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
    order = nil
    children = {}

    for entry in lfs.dir path
      continue if entry == '.' or entry == '..'
      continue if entry == 'init.moon'

      if entry == '$order'
        order = [line for line in io.lines path .. entry]
        continue

      attr = lfs.attributes path .. entry
      switch attr.mode
        when 'file'
          key, value = load_property path, entry
          .props[key] = value
        when 'directory'
          children[entry] = load_fileder path, entry
        else
          error "unknown file type: #{attr.mode}"

    if order
      -- order from order file
      for i, name in pairs order
        child = assert children[name], "child in $order but not fs: #{name} of #{path}"
        table.insert .children, child
        children[name] = nil

    -- sort remainder alphabeticalally
    for name, child in opairs children
      table.insert .children, child
      warn "child #{name} of #{path} not in $order!" if order

{
  :load_property
  :load_fileder
}
