add = (tmpl) ->
  package.path ..= ";#{tmpl}.lua"
  package.moonpath ..= ";#{tmpl}.moon"

add '?'
add '?.server'
add '?/init'
add '?/init.server'

require 'mmm'

import dir_base, Key, Fileder from require 'mmm.mmmfs.fileder'
import convert from require 'mmm.mmmfs.conversion'
import get_store from require 'mmm.mmmfs.stores'
import render from require 'mmm.mmmfs.layout'
import Browser from require 'mmm.mmmfs.browser'
import decodeURI from require 'http.util'

lfs = require 'lfs'
server = require 'http.server'
headers = require 'http.headers'

class Server
  new: (@store, opts={}) =>
    opts = {k,v for k,v in pairs opts}
    opts.host = 'localhost' unless opts.host
    opts.port = 8000 unless opts.port
    opts.onstream = @\stream
    opts.onerror = @\error

    @server = server.listen opts

    @flags = opts.flags

    if @flags.rw == nil
      @flags.rw = opts.host == 'localhost' or opts.host == '127.0.0.1'

    if @flags.unsafe == nil
      @flags.unsafe = opts.host == 'localhost' or opts.host == '127.0.0.1'

    export UNSAFE
    UNSAFE = @flags.unsafe
    require 'mmm.mmmfs'

  listen: =>
    assert @server\listen!

    _, ip, port = @server\localname!
    print "[#{@@__name}]",
          "running at #{ip}:#{port}",
          "[#{table.concat [flag for flag,on in pairs @flags when on], ', '}]"

    assert @server\loop!

  handle_interactive: (fileder, facet) =>
    root = Fileder @store
    browser = Browser root, fileder.path, facet.name

    deps = [[
    <script type="text/javascript" src="//cdnjs.cloudflare.com/ajax/libs/svg.js/2.6.6/svg.min.js"></script>
    <script type="text/javascript" src="//unpkg.com/mermaid@8.4.0/dist/mermaid.min.js"></script>
    <script type="text/javascript" src="//unpkg.com/marked@0.7.0/marked.min.js"></script>
    <link rel="stylesheet" type="text/css" href="//unpkg.com/codemirror@5.49.2/lib/codemirror.css" />
    <script type="text/javascript" src="//unpkg.com/codemirror@5.49.2/lib/codemirror.js"></script>
    <script type="text/javascript" src="//unpkg.com/codemirror@5.49.2/mode/lua/lua.js"></script>
    <script type="text/javascript" src="//unpkg.com/codemirror@5.49.2/mode/markdown/markdown.js"></script>
    <script type="text/javascript" src="//unpkg.com/codemirror@5.49.2/addon/display/autorefresh.js"></script>
    <script type="text/javascript" src="/static/fengari-web/:text/javascript"></script>
    <script type="text/lua" src="/static/mmm/:text/lua"></script>
    <script type="text/lua">require 'mmm'; require 'mmm.mmmfs'</script>]]

    render browser\todom!, fileder, noview: true, scripts: deps .. "
    <script type=\"text/lua\">
      on_load = on_load or {}
      table.insert(on_load, function()
        local path = #{string.format '%q', fileder.path}
        local facet = #{string.format '%q', facet.name}
        local browser = require 'mmm.mmmfs.browser'
        local fileder = require 'mmm.mmmfs.fileder'
        local web = require 'mmm.mmmfs.stores.web'

        local store = web.WebStore({ verbose = true })
        local root = fileder.Fileder(store, store:get_index(nil, -1))

        local err_and_trace = function (msg) return debug.traceback(msg, 2) end
        local ok, browser = xpcall(browser.Browser, err_and_trace, root, path, facet, true)
        if not ok then error(browser) end
      end)
    </script>"

  handle: (method, path, facet, value) =>
    fileder = Fileder @store, path

    if not fileder
      -- fileder not found
      404, "fileder '#{path}' not found"

    if not @flags.rw and method != 'GET' and method != 'HEAD'
      return 403, 'editing not allowed'

    switch method
      when 'GET', 'HEAD'
        val = switch facet.name
          when '?index', '?tree'
            -- serve fileder index
            -- '?index': one level deep
            -- '?tree': recursively
            depth = if facet.name == '?tree' then -1 else 1
            index = @store\get_index path, depth
            convert 'table', facet.type, index, fileder, facet.name
          else
            if facet.type == 'text/html+interactive'
              @handle_interactive fileder, facet
            else if not fileder\has_facet facet.name
              404, "facet '#{facet.name}' not found in fileder '#{path}'"
            else
              fileder\get facet

        if val
          200, val
        else
          406, "cant convert facet '#{facet.name}' to '#{facet.type}'"
      when 'POST'
        @store\create_facet path, facet.name, facet.type, value
        200, 'ok'
      when 'PUT'
        @store\update_facet path, facet.name, facet.type, value
        200, 'ok'
      when 'DELETE'
        @store\remove_facet path, facet.name, facet.type
        200, 'ok'
      else
        501, "not implemented"

  err_and_trace = (msg) -> debug.traceback msg, 2
  stream: (sv, stream) =>
    req = stream\get_headers!
    method = req\get ':method'
    path = req\get ':path'
    path = decodeURI path

    path_facet, type = path\match '(.*):(.*)'
    path_facet or= path
    path, facet = path_facet\match '(.*)/([^/]*)'

    type or= 'text/html+interactive'
    type = type\match '%s*(.*)'
    facet = Key facet, type

    value = stream\get_body_as_string!
    ok, status, body = xpcall @.handle, err_and_trace, @, method, path, facet, value
    if not ok
      warn "Error handling request (#{method} #{path} #{facet}):\n#{status}"
      body = "Internal Server Error:\n#{status}"
      status = 500

    res = headers.new!
    response_type = if status > 299 then 'text/plain'
    else if facet.type == 'text/html+interactive' then 'text/html'
    else facet.type
    res\append ':status', tostring status
    res\append 'content-type', response_type

    stream\write_headers res, method == 'HEAD'
    if method ~= 'HEAD'
      stream\write_chunk body, true

  error: (sv, ctx, op, err, errno) =>
    msg = "#{op} on #{tostring ctx} failed"
    msg = "#{msg}: #{err}" if err

-- usage:
-- moon server.moon [FLAGS] [STORE] [host] [port]
-- * FLAGS - any of the following:
--   --[no-]rw     - enable/disable POST?PUT/DELETE operations                     (default: on if local)
--   --[no-]unsafe - enable/disable server-side code execution when writable is on (default: on if local)
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

store = get_store store
server = Server store, :flags, :host, port: port and tonumber port
server\listen!
