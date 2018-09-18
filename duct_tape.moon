package.noompath = './?.noom;./?/init.noom'

local *

compile = require "moonscript.compile"
parse = require "moonscript.parse"

import smart_node, build from require "moonscript.types"
import dirsep from require "moonscript.base"
-- import split, get_options, unpack from require "moonscript.util"
import get_options, unpack from require "moonscript.util"

line_tables = require "moonscript.line_tables"
lua = :loadstring, :load

import p from require 'moon'

matches = (chain) ->
  return unless chain[1] == "chain"
  ref, call = chain[2], chain[3]
  return unless ref[1] == "ref" and call[1] == "call"
  ref[2] == "COMPILE"

transform_extract = (node) ->
  { _, ref, call } = node
  { _, call_args } = call
  fndef = smart_node call_args[1]

  if #fndef.whitelist > 1
    return 'cannot COMPILE function with whitelist!'

  code, ltable, pos = compile.tree { fndef }
  if not code
    return compile.format_error(ltable, pos, text)

  node[1] = "string"
  node[2] = "'"
  node[3] = code
  node[-1] = nil
  nil

transform_extracts = (node) ->
  if matches node
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

  err = transform_extracts tree
  if err
    return nil, err

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
  -- the unpack prevents us from passing nil
  (lua.loadstring or lua.load) code, chunk_name, unpack { mode, env }

insert_loader = (pos=2) ->
  -- if not package.moonpath
  --   package.moonpath = create_moonpath package.path

  loaders = package.loaders or package.searchers
  for loader in *loaders
    return false if loader == noom_loader

  table.insert loaders, pos, noom_loader
  true

{
  :insert_loader
}
