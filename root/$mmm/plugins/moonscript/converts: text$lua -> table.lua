if MODE == 'CLIENT' then
  return { }
end
local _, moon = assert(pcall(require, 'moonscript.base'))
local _load = moon.load or moon.loadstring
return {
  {
    inp = 'text/moonscript -> (.+)',
    out = '%1',
    cost = 1,
    transform = function(self, val, fileder, key)
      local func = _load(val, tostring(fileder) .. "#" .. tostring(key))
      return func()
    end
  },
  {
    inp = 'text/moonscript -> (.+)',
    out = 'text/lua -> %1',
    cost = 2,
    transform = function(self, val)
      return moon.to_lua(val)
    end
  }
}
