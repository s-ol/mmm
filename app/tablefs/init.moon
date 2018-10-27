export ^

interps = {
  {
    name: 'moon',
    transform: (method) => method @
  },
}

split = (str, delim='->') ->
  return {}, str if nil == str\find delim

  -- @TODO interp chain?
  interp, rest = str\match ' *(%w+) *-> *(.*)'
  { interp }, rest

class Key
  new: (opts) =>
    if 'string' == type opts
      @name, rest = opts\match '(%w+): *(.+)'
      if not @name
        @name = ''
        rest = opts
      @interps, @type = split rest, '->'
    elseif 'table' == type opts
      @name = opts.name
      @type = assert opts.type, 'no type given'
      @interps = opts.interps or {}
    else
      error 'wrong argument type'

  -- get a function that interpretes thi type according to @interps
  get_interp: (overrides) =>
    return ((val) => val) if #@interps == 0

    assert #@interps == 1, 'not supported rn' -- @TODO
    _name = @interps[1]

    return overrides[_name] if overrides and overrides[_name]

    for { :name, :transform } in *interps
      if name == _name
        return transform

    error "interp not found: '#{_name}'"

converts = {
  {
    inp: 'mmm/dom',
    out: 'text/html',
    transform: (node) -> if MODE == 'SERVER' then node else node.outerHTML
  },
  {
    inp: 'mmm/component',
    out: 'mmm/dom',
    transform: (...) ->
      import tohtml from require 'lib.component'
      tohtml ...
  },
  {
    -- @TODO this chained rule *should* be inferred, but that's way too hot rn
    inp: 'mmm/component',
    out: 'text/html',
    transform: (node) ->
      import tohtml from require 'lib.component'

      node = tohtml node
      if MODE == 'SERVER' then node else node.outerHTML
  },
}

table.insert converts, {
  inp: 'text/html',
  out: 'mmm/dom',
  transform: if MODE == 'SERVER'
    (...) -> ...
  else
    (html) ->
      tmp = document\createElement 'div'
      tmp.innerHTML = html
      tmp.firstChild
  }

do
  local markdown
  if MODE == 'SERVER'
    success, discount = pcall require, 'discount'
    markdown = discount if success
  else
    markdown = window and window\marked

  if markdown
    table.insert converts, {
      inp: 'text/markdown',
      out: 'text/html',
      transform: markdown,
    }

    -- @TODO chained w above
    table.insert converts, {
     inp: 'text/markdown',
      out: 'mmm/dom',
      transform: if MODE == 'SERVER'
        (md) -> markdown md
      else
        (md) ->
          with document\createElement 'div'
            .innerHTML = markdown md
    }

class Fileder
  new: (props, @children) =>
    if not @children
      @children = for i, child in ipairs props
        props[i] = nil
        child

    @props = { (Key k), v for k, v in pairs props }

  gett: (...) => assert @get ...
  get: (name='', type, overrides) =>
    if not type
      type = name
      name = ''

    -- first pass, interps only
    for key, value in pairs @props
      continue unless key.name == name and key.type == type

      interp = key\get_interp overrides

      return interp @, value

    if not overrides
      -- second pass, interps + converts
      for key, value in pairs @props
        continue unless key.name == name

        interp = key\get_interp!

        for { :inp, :out, :transform } in *converts
          return transform interp @, value if inp == key.type and out == type

    nil, "node doesn't have value for #{name}:#{type}"

require = relative ...
root = require '.tablefs'

append root\gett 'mmm/dom'
