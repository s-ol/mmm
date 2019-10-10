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

  listen: =>
    assert @server\listen!

    _, ip, port = @server\localname!
    print "SV", "running at #{ip}:#{port}"
    assert @server\loop!

  handle: (method, path, facet) =>
    fileder = Fileder @store, path

    if not fileder
      -- fileder not found
      404, "fileder '#{path}' not found"

    switch method
      when 'GET', 'HEAD'
        val = switch facet.name
          when '?interactive'
            export BROWSER

            root = Fileder @store
            BROWSER = Browser root, path
            render BROWSER\todom!, fileder, noview: true, scripts: "
    <script type=\"application/lua\">
      on_load = on_load or {}
      table.insert(on_load, function()
        local path = #{string.format '%q', path}
        local browser = require 'mmm.mmmfs.browser'
        local fileder = require 'mmm.mmmfs.fileder'
        local web = require 'mmm.mmmfs.stores.web'
        local root = fileder.Fileder(web.WebStore({ verbose = true }), path)

        BROWSER = browser.Browser(root, path, true)
      end)
    </script>"

          when '?index', '?tree'
            -- serve fileder index
            -- '?index': one level deep
            -- '?tree': recursively
            index = fileder\get_index facet.name == '?tree'
            convert 'table', facet.type, index
          else
            -- fileder and facet given
            if not fileder\has_facet facet.name
              return 404, "facet '#{facet.name}' not found in fileder '#{path}'"

            fileder\get facet

        if val
          200, val
        else
          406, "cant convert facet '#{facet.name}' to '#{facet.type}'"
      else
        501, "not implemented"

  stream: (sv, stream) =>
    req = stream\get_headers!
    method = req\get ':method'
    path = req\get ':path'
    path = decodeURI path

    path_facet, type = path\match '(.*):(.*)'
    path_facet or= path
    path, facet = path_facet\match '(.*)/([^/]*)'

    type or= 'text/html'
    type = type\match '%s*(.*)'
    facet = Key facet, type

    ok, status, body = pcall @.handle, @, method, path, facet
    if not ok
      warn status, body
      body = "Internal Server Error: #{status}"
      status = 500

    res = headers.new!
    response_type = if status > 299 then 'text/plain'
    else if facet then facet.type
    else 'text/json'
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
