lfs = require 'lfs'

-- split filename into dirname + basename
dir_base = (path) ->
  dir, base = path\match '(.-)([^/]-)$'
  if dir and #dir > 0
    dir = dir\sub 1, #dir - 1

  dir, base

class FSStore
  new: (opts = {}) =>
    opts.root or= 'root'
    opts.verbose or= false

    if not opts.verbose
      @log = ->

    -- ensure path doesnt end with a slash
    @root = opts.root\match '^(.-)/?$'
    @log "opening '#{opts.root}'..."

  log: (...) =>
    print "[DB]", ...

  -- fileders
  list_fileders_in: (path='') =>
    coroutine.wrap ->
      for entry_name in lfs.dir @root .. path
        continue if '.' == entry_name\sub 1, 1
        entry_path = @root .. "#{path}/#{entry_name}"
        if 'directory' == lfs.attributes entry_path, 'mode'
          coroutine.yield "#{path}/#{entry_name}"

  list_all_fileders: (path='') =>
    coroutine.wrap ->
      for path in @list_fileders_in path
        coroutine.yield path
        for p in @list_all_fileders path
          coroutine.yield p

  create_fileder: (parent, name) =>
    @log "creating fileder #{path}"
    path = "#{parent}/#{name}"
    assert lfs.mkdir @root .. path
    path

  remove_fileder: (path) =>
    @log "removing fileder #{path}"

    rmdir = (path) ->
      for file in lfs.dir path
        continue if '.' == file\sub 1, 1

        file_path = "#{path}/#{file}"
        switch lfs.attributes file_path, 'mode'
          when 'file'
            assert os.remove file_path
          when 'directory'
            assert rmdir file_path

      lfs.rmdir path

    rmdir @root .. path

  rename_fileder: (path, next_name) =>
    @log "renaming fileder #{path} -> '#{next_name}'"
    parent, name = dir_base path
    assert os.rename path, @root .. "#{parent}/#{next_name}"

  move_fileder: (path, next_parent) =>
    @log "moving fileder #{path} -> #{next_parent}/"
    parent, name = dir_base path
    assert os.rename @root .. path, @root .. "#{next_parent}/#{name}"

  -- facets
  list_facets: (path) =>
    coroutine.wrap ->
      for entry_name in lfs.dir @root .. path
        entry_path = "#{@root .. path}/#{entry_name}"
        if 'file' == lfs.attributes entry_path, 'mode'
          entry_name = (entry_name\match '(.*)%.%w+') or entry_name
          entry_name = entry_name\gsub '%$', '/'
          name, type = entry_name\match '(%w+): *(.+)'
          if not name
            name = ''
            type = entry_name

          coroutine.yield name, type

  tofp: (path, name, type) =>
    type = "#{name}: #{type}" if #name > 0
    type = type\gsub '%/', '$'
    @root .. "#{path}/#{type}"

  locate: (path, name, type) =>
    return unless lfs.attributes @root .. path, 'mode'

    type = type\gsub '%/', '$'
    name = "#{name}: " if #name > 0
    name = name .. type
    name = name\gsub '([^%w])', '%%%1'

    local file_name
    for entry_name in lfs.dir @root .. path
      if (entry_name\match "^#{name}$") or entry_name\match "^#{name}%.%w+$"
        if file_name
          error "two files match #{name}: #{file_name} and #{entry_name}!"
        file_name = entry_name


    file_name and @root .. "#{path}/#{file_name}"

  load_facet: (path, name, type) =>
    filepath = @locate path, name, type
    return unless filepath
    file = assert (io.open filepath, 'rb'), "couldn't open facet file '#{filepath}'"
    with file\read '*all'
      file\close!

  create_facet: (path, name, type, blob) =>
    @log "creating facet #{path} | #{name}: #{type}"
    assert blob, "cant create facet without value!"

    filepath = @tofp path, name, type
    if lfs.attributes filepath, 'mode'
      error "facet file already exists!"

    file = assert (io.open filepath, 'wb'), "couldn't open facet file '#{filepath}'"
    file\write blob
    file\close!

  remove_facet: (path, name, type) =>
    @log "removing facet #{path} | #{name}: #{type}"

    filepath = @locate path, name, type
    assert filepath, "couldn't locate facet!"
    assert os.remove filepath

  rename_facet: (path, name, type, next_name) =>
    @log "renaming facet #{path} | #{name}: #{type} -> #{next_name}"
    filepath = @locate path, name, type
    assert filepath, "couldn't locate facet!"
    assert os.rename filepath, @tofp path, next_name, type

  update_facet: (path, name, type, blob) =>
    @log "updating facet #{path} | #{name}: #{type}"
    filepath = @locate path, name, type
    assert filepath, "couldn't locate facet!"
    file = assert (io.open filepath, 'wb'), "couldn't open facet file '#{filepath}'"
    file\write blob
    file\close!

{
  :FSStore
}
