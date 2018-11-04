output_name = assert arg[1], "please specify the output directory"

escape = (str) -> string.format '%q', str

with io.open output_name, 'w'
  \write "local p = package.preload\n"

  for i=2, #arg
    file_name = arg[i]

    file = io.open file_name, 'r'
    code = file\read '*all'
    file\close!

    module = file_name\gsub '/', '.'
    module = module\gsub '%.lua$', ''
    module = module\gsub '%.init$', ''
    module = module\match '^dist%.(.*)'

    file_name = escape file_name
    code = escape code
    module = escape module

    \write "if not p[#{module}] then p[#{module}] = load(#{code}, #{file_name}) end\n"
