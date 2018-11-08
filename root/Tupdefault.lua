facets = tup.glob '*'
inputs = ''
for i, file in ipairs(facets) do
  inputs = inputs .. " '" .. file .. "'"
end

LUA_PATH = {}
LUA_PATH += root .. '/?.lua'
LUA_PATH += root .. '/?.server.lua'
LUA_PATH += root .. '/?/init.lua'
LUA_PATH += root .. '/?/init.server.lua'
LUA_PATH = 'LUA_PATH="' .. table.concat(LUA_PATH, ';') .. '"'

exec = LUA_PATH .. ' moon ' .. root .. '/bundle_fileder.moon'

facets += '<children>'
facets += root .. '/<modules>'

tup.rule(
  facets,
  '^ BNDL %d^ ' .. exec .. ' %d ' .. inputs .. ' -- %<children>',
  { '$bundle.lua', '../<children>' }
)
