output_name = assert arg[1], "please specify the output directory"

escape = (str) -> string.format '%q', str

readfile = (name) ->
  file = io.open name, 'r'
  with file\read '*all'
    file\close

with io.open output_name, 'w'
  -- final wrap mode
  if arg[2] == '--wrap'
    assert #arg == 3, "too many arguments for 'wrap' mode"
    bundle = arg[3]

    bundle = dofile bundle
    \write "local p = package.preload\n"
    for { :module, :file, :source } in *bundle
      module = escape module
      \write "if not p[#{module}] then p[#{module}] = load(#{escape source}, #{escape file}) end\n"

  -- iterative bundling mode
  else
    \write "return {\n"

    this = assert arg[2]
    addmod = (module, file, source) ->
      modname = "#{this}.#{module}"
      modname = this if module == 'init'
      \write "
{
  module = #{escape modname},
  file = #{escape "#{this}/#{file}"},
  source = #{escape source},
},"

    for file in *arg[3,]
      if dirname = file\match '^([%w-_]+)/%.bundle%.lua$'
        bundle = dofile file
        for { :module, :file, :source } in *bundle
          addmod module, file, source
      else
        module = file\gsub '%.lua$', ''
        continue if module\match '%.server'
        module = module\gsub '%.client$', ''
        module = module\gsub '%.init$', ''
        addmod module, file, readfile file

    \write "}"

  \close!
