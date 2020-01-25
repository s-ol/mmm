add = (tmpl) ->
  package.path ..= ";#{tmpl}.lua"
  package.moonpath ..= ";#{tmpl}.moon"

add '?'
add '?.server'
add '?/init'
add '?/init.server'

require 'mmm'

import get_store from require 'mmm.mmmfs.stores'

-- usage:
-- moon server.moon [FLAGS] [STORE] [host] [port]
-- * FLAGS - any of the following:
--   --[no-]rw     - enable/disable POST?PUT/DELETE operations                     (default: on if local)
--   --[no-]unsafe - enable/disable server-side code execution when writable is on (default: on if local or --no-rw)
-- * STORE - see mmm/mmmfs/stores/init.moon:get_store
-- * host  - interface to bind to (default localhost, set to 0.0.0.0 for public hosting)
-- * port  - port to serve from, default 8000

flags = {}
arguments = for a in *arg
  if flag = a\match '^%-%-no%-(.*)$'
    flags[flag] = false
    continue
  elseif flag = a\match '^%-%-(.*)$'
    flags[flag] = true
    continue
  else
    a

{ store, host, port } = arguments

store = get_store store, verbose: true
store\fsck!
