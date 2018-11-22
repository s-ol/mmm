tup.creategitignore()

root = tup.nodevariable '.'
build = tup.nodevariable 'build'

function lua_path()
  local LUA_PATH = {}
  LUA_PATH += root .. '/?.lua'
  LUA_PATH += root .. '/?.server.lua'
  LUA_PATH += root .. '/?/init.lua'
  LUA_PATH += root .. '/?/init.server.lua'
  return 'LUA_PATH="' .. table.concat(LUA_PATH, ';') .. '"'
end
