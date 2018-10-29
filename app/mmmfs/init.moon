require = relative ...
import get_conversions from require '.conversion'

export ^

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
  new: (props, @children) =>
    if not @children
      @children = for i, child in ipairs props
        props[i] = nil
        child

    @props = { (Key k), v for k, v in pairs props }

  -- find property key according to criteria, nil if no value or conversion path
  -- * name - property name (optional: defaults to main content)
  -- * type - wanted result type
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
  -- * name - property name (optional: defaults to main content)
  -- * type - wanted result type
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
    assert value, "node doesn't have value for #{want\tostring!}"
    value, key

root = require '.tree'
if MODE == 'CLIENT'
  import Browser from require '.browser'

  export BROWSER
  BROWSER = Browser root
  append BROWSER.node
else
  append root\get 'mmm/dom'
