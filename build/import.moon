add = (tmpl) ->
  package.path ..= ";#{tmpl}.lua"
  package.moonpath ..= ";#{tmpl}.moon"

add '?'
add '?.server'
add '?/init'
add '?/init.server'

require 'mmm'
require 'lfs'
import Fileder, Key from require 'mmm.mmmfs.fileder'
import SQLStore from require 'mmm.mmmfs.drivers.sql'

-- usage:
-- moon import.moon <root> [output.sqlite3]
{ root, store } = arg

assert root, "please specify the root directory"

-- load a fs file as a fileder facet
load_facet = (filename, filepath) ->
  key = (filename\match '(.*)%.%w+') or filename
  key = Key key\gsub '%$', '/'
  key.filename = filename

  file = assert (io.open filepath, 'rb'), "couldn't open facet file '#{filename}'"
  value = file\read '*all'
  file\close!

  key, value

with SQLStore :file, verbose: true
  import_fileder = (fileder, dirpath) ->
    for file in lfs.dir dirpath
      continue if '.' == file\sub 1, 1
      continue if file == 'Tupdefault.lua'
      continue if file == 'index.html'
      continue if file == '$order'

      filepath = "#{dirpath}/#{file}"
      switch lfs.attributes filepath, 'mode'
        when 'file'
          key, value = load_facet file, filepath
          \create_facet fileder, key.name, key.type, value
        when 'directory'
          next_fileder = \create_fileder fileder, file
          -- \create_facet next_fileder, 'name', 'alpha', file
          import_fileder next_fileder, filepath
        else
          warn "unknown entry type '#{attr.mode}'"

  import_fileder '', root
