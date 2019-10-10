require = relative ..., 1
import get_conversions, apply_conversions from require '.conversion'

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
      @name, @type = opts\match '^([%w-_]+): *(.+)$'
      if not @name
        @name = ''
        @type = opts
    elseif 'table' == type opts
      @name = opts.name
      @type = opts.type
      @original = opts.original
      @filename = opts.filename
    else
      error "wrong argument type: #{type opts}, #{type second}"

  -- format as a string (see constructor)
  tostring: =>
    if @name == ''
      @type
    else
      "#{@name}: #{@type}"

  __tostring: => @tostring!

-- Fileder itself
-- contains:
-- * @facets - Facet Map (Key to Value)
-- * @children - Children Array
class Fileder
  new: (@store, @path='') =>
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
        ipairs t

      __index: (t, k) ->
        @load! unless @loaded

        if 'string' == type k
          @walk "#{@path}/#{k}"
        else
          rawget t, k

      __newindex: (t, k, child) ->
        rawset t, k, child

        if @path == '/'
          child\mount '/'
        elseif @path
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
        canonical or= Key k
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
        k = @facet_keys[k]

        rawset t, k, v

        v = k unless v == nil
        @facet_keys[k] = v
    }

  load: =>
    @loaded = true

    for path in @store\list_fileders_in @path
      table.insert @children, Fileder @store, path

    for name, type in @store\list_facets @path
      key = Key name, type
      @facet_keys[key] = key

    _, name = dir_base @path
    @facets['name: alpha'] = name

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

  -- get an index table, listing path, facets and children
  -- optionally get recursive index
  get_index: (recursive=false) =>
    {
      path: @path
      facets: [key for str, key in pairs @facet_keys]
      children: if recursive
        [child\get_index true for child in *@children]
      else
        [{ :path } for { :path } in *@children]
    }

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
  find: (...) =>
    want = Key ...

    -- filter facets by name
    matching = [ key for str, key in pairs @facet_keys when key.name == want.name ]
    return unless #matching > 0

    -- get shortest conversion path
    shortest_path, start = get_conversions want.type, [ key.type for key in *matching ]

    if start
      for key in *matching
        if key.type == start
          return key, shortest_path

      error "couldn't find key after resolution?"

  -- get and convert facet according to criteria, nil if no value or conversion path
  -- * ... - arguments like Key
  get: (...) =>
    want = Key ...

    -- find matching key and shortest conversion path
    key, conversions = @find want

    if key
      value = apply_conversions conversions, @facets[key], @, key
      value, key

  -- like @get, throw if no value or conversion path
  gett: (...) =>
    want = Key ...

    value, key = @get want
    assert value, "#{@} doesn't have value for '#{want}'"
    value, key

  __tostring: => "Fileder:#{@path}"

{
  :Key
  :Fileder
  :dir_base
}
