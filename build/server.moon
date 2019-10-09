add = (tmpl) ->
  package.path ..= ";#{tmpl}.lua"
  package.moonpath ..= ";#{tmpl}.moon"

add '?'
add '?.server'
add '?/init'
add '?/init.server'

require 'mmm'

import Key, dir_base, load_tree from require 'mmm.mmmfs.fileder'
import get_store from require 'mmm.mmmfs.stores'
import decodeURI from require 'http.util'

lfs = require 'lfs'
server = require 'http.server'
headers = require 'http.headers'

tojson = (obj) ->
  switch type obj
    when 'string'
      string.format '%q', obj
    when 'table'
      if obj[1] or not next obj
        "[#{table.concat [tojson c for c in *obj], ','}]"
      else
        "{#{table.concat ["#{tojson k}: #{tojson v}" for k,v in pairs obj], ', '}}"
    when 'number'
      tostring obj
    when 'boolean'
      tostring obj
    when nil
      'null'

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
    fileder = load_tree @store, path -- @tree\walk path
    switch method
      when 'GET', 'HEAD'
        if fileder and facet
          -- fileder and facet given
          if not fileder\has_facet facet.name
            return 404, "facet '#{facet.name}' not found in fileder '#{path}'"

          val = fileder\get facet
          if val
            200, val
          else
            406, "cant convert facet '#{facet.name}' to '#{facet.type}'"
        elseif fileder
          -- no facet given
          facets = [{k.name, k.type} for k,v in pairs fileder.facets]
          children = [f.path for f in *fileder.children]
          contents = tojson :facets, :children
          200, contents
        else
          -- fileder not found
          404, "fileder '#{path}' not found"
      else
        501, "not implemented"

  handle_static: (method, path, stream) =>
    path = path\match '^/%.static/(.*)'
    return unless path

    respond = (code, type, body) ->
      res = headers.new!
      res\upsert ':status', code
      res\append 'content-type', type

      assert stream\write_headers res, method == 'HEAD'
      if body and method ~= 'HEAD'
        assert stream\write_body_from_string body

    if method ~= 'GET' and method ~= 'HEAD'
      respond '405', 'text/plain', "can only GET/HEAD static resources"
      return true

    if path\match '%.%.' or path\match '^%~'
      respond '404', 'text/plain', "not found"
      return

    file_path = "static/#{path}"
    if 'file' == lfs.attributes file_path, 'mode'
      fd, err, errno = io.open file_path, 'rb'

      if not fd
        code = switch errno
          when ce.ENOENT then '404'
          when ce.EACCES then '403'
          else '503'

        respond code, 'text/plain', err or ''

      else
        suffix = file_path\match '%.([a-z]+)$'
        type = switch suffix
          when 'css' then 'text/css'
          when 'lua' then 'application/lua'
          when 'js' then 'application/javascript'
          else 'application/octet-stream'

        respond '200', type, nil
        if method ~= 'HEAD'
          assert stream\write_body_from_file fd
    else
      respond '404', 'text/plain', "not found"

    true

  stream: (sv, stream) =>
    req = stream\get_headers!
    method = req\get ':method'
    path = req\get ':path'
    path = decodeURI path

    -- serve static assets, cheap hack for now
    return if @handle_static method, path, stream

    path_facet, type = path\match '(.*):(.*)'
    path_facet or= path
    path, facet = path_facet\match '(.*)/([^/]*)'

    if facet ~= '?index'
      type or= 'text/html'
      type = type\match '%s*(.*)'
      facet = Key facet, type
    else
      facet = nil

    status, body = @handle method, path, facet

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
    print msg

-- usage:
-- moon server.moon [STORE] [host] [port]
{ store, host, port } = arg

store = get_store store
server = Server store, :host, port: port and tonumber port
server\listen!
