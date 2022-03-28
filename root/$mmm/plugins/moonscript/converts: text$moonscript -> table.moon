if MODE == 'CLIENT'
  return {}

_, moon = assert pcall require, 'moonscript.base'
_load = moon.load or moon.loadstring

{
  {
    inp: 'text/moonscript -> (.+)',
    out: '%1',
    cost: 1
    transform: (val, fileder, key) =>
      func = _load val, "#{fileder}##{key}"
      func!
  },
  {
    inp: 'text/moonscript -> (.+)',
    out: 'text/lua -> %1',
    cost: 2
    transform: (val) => moon.to_lua val
  },
}
