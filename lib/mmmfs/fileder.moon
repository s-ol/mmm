require = relative ..., 1
import get_conversions from require '.conversion'

-- Key of a Fileder Property
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
    else
      error "wrong argument type: #{type opts}, #{type second}"

  -- format as a string (see constructor)
  tostring: =>
    if @name == ''
      @type
    else
      "#{@name}: #{@type}"

-- Fileder itself
-- contains:
-- * @props - Property Map (Key to Value)
-- * @children - Children Array
class Fileder
  -- instantiate from props and children tables
  -- or mix in one table (numeric keys are children, remainder props)
  -- prop-keys are passed to Key constructor
  new: (props, children) =>
    if not children
      children = for i, child in ipairs props
        props[i] = nil
        child

    -- automatically mount children on insert
    @children = setmetatable {}, __newindex: (t, k, child) ->
      rawset t, k, child
      if @path == '/'
        child\mount '/'
      elseif @path
        child\mount @path .. '/'

    -- copy children
    for i, child in ipairs children
      @children[i] = child

    -- automatically reify string keys on insert
    @props = setmetatable {}, __newindex: (t, key, v) ->
      rawset t, key, nil -- fix for fengari.io
      rawset t, (Key key), v

    -- copy props
    for k, v in pairs props
      @props[k] = v

  -- recursively walk to and return the fileder with @path == path
  -- * path - the path to walk to
  walk: (path) =>
    -- early-out if we are outside of the path already
    return unless path\match '^' .. @path

    -- gotcha
    return @ if path == @path

    for child in *@children
      result = child\walk path
      return result if result

  -- recursively mount fileder and children at path
  -- * path - the path to mount at (default: '/')
  -- * mount_as - dont append own name to path
  mount: (path='/', mount_as=false) =>
    assert not @path, "mounted twice: #{@path} and now #{path}"

    if mount_as
      @path = path
    else
      @path = path .. @gett 'name: alpha'

    if @path == '/'
      for child in *@children
        child\mount '/'
    else
      for child in *@children
        child\mount @path .. '/'

  -- recursively iterate all children (coroutine)
  -- * depth - depth to stop after; 1 = yield only self (default: infinite)
  iterate: (depth=0) =>
    coroutine.yield @
    return if depth == 1

    for child in *@children
      child\iterate depth - 1

  -- find property key according to criteria, nil if no value or conversion path
  -- * ... - arguments like Key
  find: (...) =>
    want = Key ...

    -- filter props by name
    matching = [ key for key in pairs @props when key.name == want.name ]
    return unless #matching > 0

    -- get shortest conversion path
    shortest_path, start = get_conversions want.type, [ key.type for key in *matching ]

    if start
      for key in *matching
        if key.type == start
          return key, shortest_path

      error "couldn't find key after resolution?"

  -- get property according to criteria, nil if no value or conversion path
  -- * ... - arguments like Key
  get: (...) =>
    want = Key ...

    -- find matching key and shortest conversion path
    key, conversions = @find want

    if key
      value = @props[key]

      -- apply conversions (in reverse order)
      for i=#conversions,1,-1
        { :inp, :out, :transform } = conversions[i]
        value = transform value, @

      value, key

  -- like @get, throw if no value or conversion path
  gett: (...) =>
    want = Key ...

    value, key = @get want
    assert value, "node doesn't have value for '#{want\tostring!}'"
    value, key

{
  :Key
  :Fileder
}
