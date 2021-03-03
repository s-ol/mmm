import get_conversions, apply_conversions from require 'mmm.mmmfs.conversion'

-- split filename into dirname + basename
dir_base = (path) ->
  dir, base = path\match '(.-)([^/]-)$'
  if dir and #dir > 0
    dir = dir\sub 1, #dir - 1

  dir, base

-- Key of a Fileder Facet
-- contains:
-- * @name - key name or '' for main content
-- * @type - type string (type -> type -> type)
class Key
  -- instantiate from table w/ keys described above
  -- or string like '@name: @type' (name optional)
  new: (opts, second) =>
    if 'string' == type second
      @name, @type = (opts or ''), second
    elseif 'string' == type opts
      @name, @type = opts\match '^([%w-_]*): *(.+)$'
      if not @name
        @name = ''
        @type = opts\match '^ *(.+)$'
    elseif 'table' == type opts
      @name = opts.name or ''
      @type = opts.type
    else
      error "wrong argument type: #{type opts}, #{type second}"

    assert ('string' == type @name), "name is not a string: '#{@name}'"
    assert ('string' == type @type), "type is not a string: '#{@type}'"

  -- format as a string (see constructor)
  -- in strict mode never omit name
  tostring: (strict=false) =>
    if not strict and @name == ''
      @type
    else
      "#{@name}: #{@type}"

  __tostring: => @tostring!

-- stateless iterator for implementing __ipairs
inext = (tbl, i) ->
  i += 1
  if v = tbl[i]
    i, v

-- Fileder itself
-- contains:
-- * @facets - Facet Map (Key to Value)
-- * @children - Children Array
class Fileder
  new: (@store, @path='', @root=@) =>
    @loaded = false

    -- lazy-load children,
    -- allow indexing by name as well as numeric index,
    -- automatically mount children on insert
    @children = setmetatable {}, {
      __len: (t) ->
        @load! unless @loaded
        rawlen t

      __ipairs: (t) ->
        @load! unless @loaded
        inext, t, 0

      __index: (t, k) ->
        @load! unless @loaded
        if 'string' == type(k) and '$' != k\sub(1,1)
          @walk "#{@path}/#{k}"

      __newindex: (t, k, child) ->
        rawset t, k, child
        return if child.path
        child\mount @path .. '/'
    }

    -- lazy-load facets,
    -- allow indexing by name as well as numeric index,
    -- automatically mount children on insert

    -- we need to store the presence of facets separately from the actual (cached) value,
    -- because we want to lazily load the tree (index) *and* facet contents.
    -- @facet_keys maps from key-strings to Key instances ('canonical Key instances')
    -- @facets maps from canonical keys to cached values and lazy-loads.
    -- both maps automatically rewrite __index and __newindex for both Key instances and strings.
    @facet_keys = setmetatable {}, {
      __pairs: (t) ->
        @load! unless @loaded
        next, t

      __index: (t, k) ->
        canonical = rawget t, tostring k
        -- canonical or= Key k
        canonical

      __newindex: (t, k, v) ->
        k = Key k
        rawset t, (tostring k), v
    }
    @facets = setmetatable {}, {
      __index: (t, k) ->
        @load! unless @loaded

        -- get canonical Key instance
        k = @facet_keys[k]
        return unless k

        -- if cached, return
        if v = rawget t, k
          return v

        with v = @store\load_facet @path, k.name, k.type
          rawset t, k, v

      __pairs: (t) ->
        @load! unless @loaded

        -- force cache all facets
        for k, v in pairs @facet_keys
          t[v]

        next, t

      __newindex: (t, k, v) ->
        -- get canonical Key instance
        key = @facet_keys[k]

        -- new creating, also create canonical Key
        if not key
          key = Key k
          @facet_keys[key] = key

        rawset t, key, v

        -- when deleting, also delete canonical Key
        if not v
          @facet_keys[key] = nil
    }

    -- this fails with JS objects from JSON.parse
    if 'table' == type @path
      index = @path
      @path = index.path
      @load index

    assert ('string' == type @path), "invalid path: '#{@path}'"

  -- load fact/children contents
  -- called automatically by metamethods set up in constructor
  -- can take an index instance if it is already available
  load: (index) =>
    assert not @loaded, "already loaded!"
    @loaded = true

    index or= @store\get_index @path

    for path_or_index in *index.children
      child = Fileder @store, path_or_index, @root
      name = child\get 'name: alpha'
      if '$' != name\sub 1, 1
        table.insert @children, child
      else
        @children[name] = child

    for key in *index.facets
      key = Key key
      @facet_keys[key] = key

      if MODE == 'CLIENT' and key.type\match 'text/moonscript'
        -- @TODO: this doesn't belong here
        copy = Key key.name, key.type\gsub 'text/moonscript', 'text/lua'
        @facet_keys[copy] = copy

    _, name = dir_base @path
    name_key = Key 'name: alpha'
    @facet_keys[name_key] = name_key
    @facets[name_key] = name

  -- recursively walk to and return the fileder with @path == path
  -- * path - the path to walk to
  walk: (path) =>
    -- fix relative paths
    return @ if path == ''
    path = "#{@path}/#{path}" if '/' != path\sub 1, 1

    -- early-out if we are outside of the path already
    return unless @path == path\sub 1, #@path

    -- gotcha
    return @ if #path == #@path

    @load! unless @loaded

    if match = @children['$mmm'] and @children['$mmm']\walk path
      return match

    for child in *@children
      if match = child\walk path
        return match

  -- recursively mount fileder and children at path
  -- * path - the path to mount at
  -- * mount_as - dont append own name to path
  mount: (path, mount_as) =>
    if not mount_as
      path ..= @gett 'name: alpha'

    assert not @path or @path == path, "mounted twice: #{@path} and now #{path}"

    @path = path

    for child in *@children
      child\mount @path .. '/'

  -- recursively iterate all children (coroutine)
  -- * depth - depth to stop after; 1 = yield only self (default: infinite)
  iterate: (depth=0) =>
    coroutine.yield @
    return if depth == 1

    for child in *@children
      child\iterate depth - 1

  -- get all facet names (list)
  get_facets: =>
    names = {}
    for str, key in pairs @facet_keys
      names[key.name] = true

    [name for name in pairs names]

  -- check whether a facet is directly available
  has: (...) =>
    want = Key ...

    @facet_keys[want]

  -- check whether any facet with that name exists
  has_facet: (want) =>
    for str, key in pairs @facet_keys
      continue if key.original

      if key.name == want
        return key

  -- find facet and type according to criteria, nil if no value or conversion path
  -- * ... - arguments like Key
  find: (key, key2, ...) =>
    want = Key key, key2

    -- filter facets by name
    matching = [ key for str, key in pairs @facet_keys when key.name == want.name ]
    return unless #matching > 0

    -- get shortest conversion path
    shortest_path, start = get_conversions @, want.type, [ key.type for key in *matching ], ...

    if start
      for key in *matching
        if key.type == start
          return key, shortest_path

      error "couldn't find key after resolution?"

  -- get and convert facet according to criteria, nil if no value or conversion path
  -- * ... - arguments like Key
  get: (...) =>
    want = Key ...

    -- return directly if present
    if val = @facets[want]
      return val, want

    if val = CACHE and CACHE\get @, want
      return val, want

    -- find matching key and shortest conversion path
    key, conversions = @find want

    if key
      value = apply_conversions @, conversions, @facets[key], key
      CACHE\set @, want, value if CACHE
      value, key

  -- like @get, throw if no value or conversion path
  gett: (...) =>
    want = Key ...

    value, key = @get want
    assert value, "#{@} doesn't have value for '#{want}'"
    value, key

  -- set a facet value and propagate to the store
  set: (key, key2, value) =>
    if value
      key = Key key, key2
    else
      key = Key key
      value = key2

    if value == nil
      @store\remove_facet @path, key.name, key.type
    elseif @facet_keys[key]
      @store\update_facet @path, key.name, key.type, value
    else
      @store\create_facet @path, key.name, key.type, value

    @facets[key] = value

  -- add a child fileder with given name
  add_child: (name) =>
    new_path = @store\create_fileder @path, name
    with new_child = Fileder @store, new_path, @root
      table.insert @children, new_child

  -- remove a child with given index
  remove_child: (i) =>
    removed = table.remove @children, i
    assert removed, "no such child fileder"
    @store\remove_fileder removed.path

  swap_children: (ia, ib) =>
    a, b = @children[ia], @children[ib]
    @store\swap_fileders @path, (a\gett 'name: alpha'), (b\gett 'name: alpha')
    @children[ia], @children[ib] = b, a

  __tostring: => "Fileder:#{@path}"

{
  :Key
  :Fileder
  :dir_base
}
