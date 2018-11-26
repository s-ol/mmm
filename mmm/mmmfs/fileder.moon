require = relative ..., 1
import get_conversions, apply_conversions from require '.conversion'

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
      @name, @type = opts\match '(%w+): *(.+)'
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
  -- instantiate from facets and children tables
  -- or mix in one table (numeric keys are children, remainder facets)
  -- facet-keys are passed to Key constructor
  new: (facets, children) =>
    if not children
      children = for i, child in ipairs facets
        facets[i] = nil
        child

    -- automatically mount children on insert
    @children = setmetatable {}, {
      __index: (t, k) ->
        return rawget t, k unless 'string' == type k

        @walk "#{@path}/#{k}"

      __newindex: (t, k, child) ->
        rawset t, k, child
        if @path == '/'
          child\mount '/'
        elseif @path
          child\mount @path .. '/'
    }

    -- copy children
    for i, child in ipairs children
      @children[i] = child

    -- automatically reify string keys on insert
    @facets = setmetatable {}, __newindex: (t, key, v) ->
      rawset t, (Key key), v

    -- copy facets
    for k, v in pairs facets
      @facets[k] = v

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
    assert not @path, "mounted twice: #{@path} and now #{path}"

    @path = path
    if not mount_as
      @path ..= @gett 'name: alpha'

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
    for key in pairs @facets
      names[key.name] = true

    [name for name in pairs names]

  -- check whether a facet is directly available
  has: (...) =>
    want = Key ...

    for key in pairs @facets
      continue if key.original

      if key.name == want.name and key.type == want.type
        return key

  -- find facet and type according to criteria, nil if no value or conversion path
  -- * ... - arguments like Key
  find: (...) =>
    want = Key ...

    -- filter facets by name
    matching = [ key for key in pairs @facets when key.name == want.name ]
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
}
