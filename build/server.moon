add = (tmpl) ->
  package.path ..= ";#{tmpl}.lua"
  package.moonpath ..= ";#{tmpl}.moon"

add '?'
add '?.server'
add '?/init'
add '?/init.server'

require 'mmm'

export UNSAFE
UNSAFE = true

import dir_base, Key, Fileder from require 'mmm.mmmfs.fileder'
import convert, MermaidDebugger from require 'mmm.mmmfs.conversion'
import get_store from require 'mmm.mmmfs.stores'
import render from require 'mmm.mmmfs.layout'
import Browser from require 'mmm.mmmfs.browser'
import init_cache from require 'mmm.mmmfs.cache'
import decodeURI from require 'http.util'

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
      @flags.unsafe = not @flags.rw or opts.host == 'localhost' or opts.host == '127.0.0.1'

    if @flags.cache
      assert not @flags.rw, "--rw and --cache are incompatible"
      @root = Fileder @store
      init_cache!

    -- @TODO: fix UNSAFE!
    UNSAFE = @flags.unsafe

  listen: =>
    assert @server\listen!

    _, ip, port = @server\localname!
    print "[#{@@__name}]",
          "running at #{ip}:#{port}",
          "[#{table.concat [flag for flag,on in pairs @flags when on], ', '}]"

    assert @server\loop!

  handle_interactive: (fileder, facet) =>
    root = @root or Fileder @store
    browser = Browser root, fileder.path, facet.name

    render browser\todom!, fileder, noview: true, scripts: "
    <script type=\"text/javascript\" src=\"//cdnjs.cloudflare.com/ajax/libs/svg.js/2.6.6/svg.min.js\"></script>
    <script type=\"text/javascript\" src=\"/static/fengari-web/:text/javascript\"></script>
    <script type=\"text/lua\" src=\"/static/mmm/:text/lua\"></script>
    <script type=\"text/lua\">
      require 'mmm'
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

  handle_debug: (fileder, facet) =>
    debugger = MermaidDebugger!
    fileder\find facet, nil, nil, nil, debugger
    print debugger\render!
    convert 'text/mermaid-graph', 'text/html', debugger\render!, fileder, facet.name

  handle: (method, path, facet, value) =>
    if not @flags.rw and method != 'GET' and method != 'HEAD'
      return 403, 'editing not allowed'

    switch method
      when 'GET', 'HEAD'
        root = @root or Fileder @store
        export BROWSER
        BROWSER = :path
        fileder = root\walk path

        if not fileder
          -- fileder not found
          return 404, "fileder '#{path}' not found"

        val = switch facet.name
          when '?index', '?tree'
            -- serve fileder index
            -- '?index': one level deep
            -- '?tree': recursively
            depth = if facet.name == '?tree' then -1 else 1
            index = @store\get_index path, depth
            convert 'table', facet.type, index, fileder, facet.name
          else
            if facet.type == '?'
              facet.type = 'text/html'
              current = fileder
              while current
                if type = current\get '_web_view: type'
                  facet.type = type\match '^%s*(.-)%s*$'
                  break

                if current.path == ''
                  break

                path, _ = dir_base current.path
                current = root\walk path

            if facet.type == 'text/html+interactive'
              @handle_interactive fileder, facet
            else if base = facet.type\match '^DEBUG %-> (.*)'
              facet.type = base
              @handle_debug fileder, facet
            else if not fileder\has_facet facet.name
              404, "facet '#{facet.name}' not found in fileder '#{path}'"
            else
              fileder\get facet

        if val
          200, val
        else
          406, "cant convert facet '#{facet.name}' to '#{facet.type}'"
      when 'POST'
        if facet
          @store\create_facet path, facet.name, facet.type, value
          200, 'ok'
        else
          200, @store\create_fileder dir_base path
      when 'PUT'
        if facet
          @store\update_facet path, facet.name, facet.type, value
          200, 'ok'
        else
          cmd, args = value\match '^([^\n]+)\n(.*)'
          switch cmd
            when 'swap'
              child_a, child_b = args\match '^([^\n]+)\n([^\n]+)$'
              assert child_a and child_b, "invalid arguments"

              @store\swap_fileders path, child_a, child_b
              200, 'ok'
            when nil
              400, "invalid request"
            else
              501, "unknown command #{cmd}"
      when 'DELETE'
        if facet
          @store\remove_facet path, facet.name, facet.type
        else
          @store\remove_fileder path
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

    facet = if facet == '' and (not type or type == '') and method ~= 'GET' and method ~= 'HEAD'
      nil
    else
      type or= '?'
      type = type\match '%s*(.*)'
      Key facet, type

    value = stream\get_body_as_string!
    ok, status, body = xpcall @.handle, err_and_trace, @, method, path, facet, value
    if not ok
      warn "Error handling request (#{method} #{path} #{facet}):\n#{status}"
      body = "Internal Server Error:\n#{status}"
      status = 500

    res = headers.new!
    response_type = if status > 299 then 'text/plain'
    else if facet and facet.type == 'text/html+interactive' then 'text/html'
    else if facet then facet.type
    else 'text/plain'
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
--   --[no-]unsafe - enable/disable server-side code execution when writable is on (default: on if local or --no-rw)
--   --[no-]cache  - cache all fileder contents                                    (default: off)
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
