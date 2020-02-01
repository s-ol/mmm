require = relative ..., 1
lfs = require 'lfs'
import Store from require '.'

-- split filename into dirname + basename
dir_base = (path) ->
  dir, base = path\match '(.-)([^/]-)$'
  if dir and #dir > 0
    dir = dir\sub 1, #dir - 1

  dir, base

class FSStore extends Store
  new: (opts = {}) =>
    super opts

    opts.root or= 'root'

    -- ensure path doesnt end with a slash
    @root = opts.root\match '^(.-)/?$'
    @log "opening '#{opts.root}'..."

  -- fileders
  get_order: (path, forgiving=false) =>
    entries = {}
    for name in lfs.dir @root .. path
      continue if '.' == name\sub 1, 1
      entry_path = @root .. "#{path}/#{name}"
      if 'directory' ~= lfs.attributes entry_path, 'mode'
        continue

      entries[name] = :name, path: "#{path}/#{name}"

    sorted = {}
    order_file = @root .. "#{path}/$order"
    if 'file' == lfs.attributes order_file, 'mode'
      for line in io.lines order_file
        entry = entries[line]
        if not entry
          if forgiving
            @log "removed stale entry '#{line}' from #{path}/$order"
            continue
          error "entry in $order but not on disk: #{line}"

        table.insert sorted, entry
        sorted[line] = true

    unsorted = [entry for name, entry in pairs entries when not sorted[entry.name]]
    if forgiving
      for entry in *unsorted
        @log "adding new entry '#{entry.name}' in #{path}/$order"
        table.insert sorted, entry
    else
      assert #unsorted == 0, unsorted[1] and "entry on disk but not in $order: #{unsorted[1].path}"

    sorted

  write_order: (path, order=@get_order path, true) =>
    order_file = @root .. "#{path}/$order"
    if #order == 0
      os.remove order_file
      return

    file = assert io.open order_file, 'w'
    for { :name } in *order
      file\write "#{name}\n"
    file\close!

  list_fileders_in: (path='') =>
    sorted = @get_order path

    coroutine.wrap ->
      for { :path } in *sorted
        coroutine.yield path

  create_fileder: (parent, name) =>
    path = "#{parent}/#{name}"
    @log "creating fileder #{path}"
    assert lfs.mkdir @root .. path
    @write_order parent
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

    parent = dir_base path
    @write_order parent

  rename_fileder: (path, next_name) =>
    @log "renaming fileder #{path} -> '#{next_name}'"
    parent, name = dir_base path
    assert os.rename path, @root .. "#{parent}/#{next_name}"

  move_fileder: (path, next_parent) =>
    @log "moving fileder #{path} -> #{next_parent}/"
    parent, name = dir_base path
    assert os.rename @root .. path, @root .. "#{next_parent}/#{name}"

  -- swap two childrens' order
  swap_fileders: (parent, name_a, name_b) =>
    @log "swapping #{name_a} and #{name_b} in #{parent}"
    order = @get_order parent
    local a, b
    for i, entry in ipairs order
      a = i if entry.name == name_a
      b = i if entry.name == name_b
      break if a and b

    assert a, "couldn't find #{parent}/#{name_a} in $order"
    assert b, "couldn't find #{parent}/#{name_b} in $order"

    order[a], order[b] = order[b], order[a]
    @write_order parent, order

  -- facets
  list_facets: (path) =>
    coroutine.wrap ->
      for entry_name in lfs.dir @root .. path
        continue if '.' == entry_name\sub 1, 1
        continue if entry_name == '$order'
        entry_path = "#{@root .. path}/#{entry_name}"
        if 'file' == lfs.attributes entry_path, 'mode'
          entry_name = (entry_name\match '(.*)%.%w+') or entry_name
          entry_name = entry_name\gsub '%$', '/'
          name, type = entry_name\match '([%w-_]+): *(.+)'
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
      continue if '.' == entry_name\sub 1, 1
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

    filepath = @locate path, name, type
    assert not filepath, "facet file already exists!"

    filepath = @tofp path, name, type
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

  -- fsck
  fsck: (path='') =>
    order = @get_order path, true
    @write_order path, order

    for { :path } in *order
      @fsck path

{
  :FSStore
}
