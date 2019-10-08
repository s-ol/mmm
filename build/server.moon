add = (tmpl) ->
  package.path ..= ";#{tmpl}.lua"
  package.moonpath ..= ";#{tmpl}.moon"

add '?'
add '?.server'
add '?/init'
add '?/init.server'

require 'mmm'

import dir_base, load_tree from require 'build.util'
import Key from require 'mmm.mmmfs.fileder'
import SQLStore from require 'mmm.mmmfs.drivers.sql'

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
  new: (@tree, opts={}) =>
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
    fileder = @tree\walk path
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
            406, 'cant convert facet'
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
        501, 'not implemented'

  stream: (sv, stream) =>
    req = stream\get_headers!
    method = req\get ':method'
    path = req\get ':path'

    if path\match '^/%?'
      -- serve static assets, cheap hack for now

      res = headers.new!
      if method ~= 'GET' and method ~= 'HEAD'
        res\append ':status', '405'
        stream\write_headers res, true
        return

      static_path = "static/#{path\sub 3}"

      if 'file' == lfs.attributes static_path, 'mode'
        fd, err, errno = io.open static_path, 'rb'

        if not fd
          code = switch errno
            when ce.ENOENT then '404'
            when ce.EACCES then '403'
            else '503'

          res\upsert ':status', code
          res\append 'content-type', 'text/plain'

          assert stream\write_headers res, method == 'HEAD'
          if method ~= 'HEAD'
            assert stream\write_body_from_string err

        else
          suffix = static_path\match '%.([a-z]+)$'
          type = switch suffix
            when 'css' then 'text/css'
            when 'lua' then 'application/lua'
            when 'js' then 'application/javascript'
            else 'application/octet-stream'

          res\upsert ':status', '200'
          res\append 'content-type', type

          assert stream\write_headers res, method == 'HEAD'
          if method ~= 'HEAD'
            assert stream\write_body_from_file fd
      else
        res\upsert ':status', '404'
        res\append 'content-type', 'text/plain'

        assert stream\write_headers res, method == 'HEAD'
        if method ~= 'HEAD'
          assert stream\write_body_from_string "not found"

      return

    path, facet = dir_base path
    facet = if #facet > 0
      facet = '' if facet == ':'
      accept = req\get 'mmm-accept'
      Key facet, accept or 'text/html'
    else
      nil

    status, body = @handle method, path, facet

    res = headers.new!
    response_type = if status > 299 then 'text/plain'
    else if facet then facet.type
    else 'text/json'
    res\append ':status', tostring status
    res\append 'content-type', response_type

    if method == 'HEAD'
      stream\write_headers res, true
    else
      stream\write_headers res, false
      stream\write_chunk body, true

  error: (sv, ctx, op, err, errno) =>
    msg = "#{op} on #{tostring ctx} failed"
    msg = "#{msg}: #{err}" if err
    print msg

-- usage:
-- moon server.moon [db.sqlite3]
{ file } = arg

tree = load_tree SQLStore :file
server = Server tree
server\listen!
