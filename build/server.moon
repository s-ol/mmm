add = (tmpl) ->
  package.path ..= ";#{tmpl}.lua"
  package.moonpath ..= ";#{tmpl}.moon"

add '?'
add '?.server'
add '?/init'
add '?/init.server'

require 'mmm'
require 'mmm.mmmfs'

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

  listen: =>
    assert @server\listen!

    _, ip, port = @server\localname!
    print "[#{@@__name}]", "running at #{ip}:#{port}"
    assert @server\loop!

  handle: (method, path, facet) =>
    fileder = Fileder @store, path

    if not fileder
      -- fileder not found
      404, "fileder '#{path}' not found"

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
              root = Fileder @store
              browser = Browser root, path, facet.name

              deps = [[
    <script type="text/javascript" src="//cdnjs.cloudflare.com/ajax/libs/svg.js/2.6.6/svg.min.js"></script>
    <script type="text/javascript" src="//unpkg.com/mermaid@8.4.0/dist/mermaid.min.js"></script>
    <script type="text/javascript" src="//unpkg.com/marked@0.7.0/marked.min.js"></script>
    <script type="text/javascript" src="/static/fengari-web/:text/javascript"></script>
    <script type="text/lua" src="/static/mmm/:text/lua"></script>
    <script type="text/lua">require 'mmm'; require 'mmm.mmmfs'</script>
              ]]

              render browser\todom!, fileder, noview: true, scripts: deps .. "
      <script type=\"text/lua\">
        on_load = on_load or {}
        table.insert(on_load, function()
          local path = #{string.format '%q', path}
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
            else if not fileder\has_facet facet.name
              404, "facet '#{facet.name}' not found in fileder '#{path}'"
            else
              fileder\get facet

        if val
          200, val
        else
          406, "cant convert facet '#{facet.name}' to '#{facet.type}'"
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

    ok, status, body = xpcall @.handle, err_and_trace, @, method, path, facet
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
-- moon server.moon [STORE] [host] [port]
{ store, host, port } = arg

store = get_store store
server = Server store, :host, port: port and tonumber port
server\listen!
