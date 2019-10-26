import a, article, h1, p from require 'mmm.dom'

moonscript = a 'MoonScript', href: 'https://moonscript.org/'
lua = a 'Lua', href: 'https://www.lua.org/'
fengari = a 'fengari.io', href: 'https://fengari.io/'

article {
  h1 'MoonScript',
  p moonscript, " is compiled to ", lua, " on the server, which is then executed on the client using ", fengari, "."
}
