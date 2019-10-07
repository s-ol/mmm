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
          print facets
          print children
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

    path, facet = dir_base path
    print "'#{path}', '#{facet}'"
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
    else 'text/plain'
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
