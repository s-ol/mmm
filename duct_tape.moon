-- package.noompath = './?.noom;./?/init.noom'
package.noompath = './?.moon;./?/init.moon'

export __FNDEF_NOOM_CACHE
__FNDEF_NOOM_CACHE = {}

assert MODE == 'SERVER', "duct_tape only works on the server"

compile = require 'moonscript.compile'
parse = require 'moonscript.parse'

import smart_node, build from require 'moonscript.types'
import dirsep from require 'moonscript.base'
import get_options, unpack from require 'moonscript.util'

line_tables = require 'moonscript.line_tables'
lua = :loadstring, :load

import p from require 'moon'

local *

clone = (a) -> { k,v for k,v in pairs a }
transform_extract = (node) ->
  fndef = clone node

  -- if #fndef.whitelist > 1
  --   return "cannot COMPILE function with whitelist!"

  -- compile the function to Lua separately
  code, ltable, pos = compile.tree { clone fndef }
  if not code
    return compile.format_error(ltable, pos, text)

  -- mutate the node in-place
  node[1] = 'do'
  for i=2,5
    node[i] = nil

  -- assign the lua code to __FNDEF_NOOM_CACHE[function] so it can be retrieved by `compile`
  fn = { 'ref', 'fn' }
  reference = build.chain {
    base: '__FNDEF_NOOM_CACHE',
    { 'index', fn }
  }

  node[2] = {
    { 'declare_with_shadows', { 'fn' } }
    build.assign_one fn, fndef
    build.assign_one reference, { 'string', '[[', code }
    fn
  }

  nil

transform_extracts = (node) ->
  if node[1] == "fndef"
    transform_extract node
  else
    err = nil
    for v in *node
      err or= transform_extracts v if 'table' == type v
    err

to_lua = (text, options={}) ->
  if "string" != type text
    t = type text
    return nil, "expecting string (got ".. t ..")"

  tree, err = parse.string text
  if not tree
    return nil, err

  p tree

  err = transform_extracts tree
  if err
    return nil, err

  p tree

  code, ltable, pos = compile.tree tree, options
  if not code
    return nil, compile.format_error(ltable, pos, text)

  code, ltable

noom_loader = (name) ->
  name_path = name\gsub "%.", dirsep

  local file, file_path
  for path in package.noompath\gmatch "[^;]+"
    file_path = path\gsub "?", name_path
    file = io.open file_path
    break if file

  if file
    text = file\read "*a"
    file\close!
    res, err = loadstring text, "@#{file_path}"
    if not res
        error file_path .. ": " .. err

    return res

  return nil, "Could not find noom file"

loadstring = (...) ->
  options, str, chunk_name, mode, env = get_options ...
  chunk_name or= "=(noom.loadstring)"

  code, ltable_or_err = to_lua str, options
  unless code
    return nil, ltable_or_err

  line_tables[chunk_name] = ltable_or_err if chunk_name

  print "#{chunk_name} compiled to:"
  print code

  -- the unpack prevents us from passing nil
  (lua.loadstring or lua.load) code, chunk_name, unpack { mode, env }

do
  local compile
  insert_loader = (pos=2) ->
    -- if not package.moonpath
    --   package.moonpath = create_moonpath package.path

    loaders = package.loaders or package.searchers
    for loader in *loaders
      return false if loader == noom_loader

    table.insert loaders, pos, noom_loader
    true

  compile = (fn) -> with code = __FNDEF_NOOM_CACHE[fn]
    assert code, 'cannot compile function not loaded from noomscript source.'

  {
    :insert_loader
    :compile
  }
