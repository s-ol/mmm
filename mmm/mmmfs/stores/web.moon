-- split filename into dirname + basename
dir_base = (path) ->
  dir, base = path\match '(.-)([^/]-)$'
  if dir and #dir > 0
    dir = dir\sub 1, #dir - 1

  dir, base

{ :location, :XMLHttpRequest, :JSON } = js.global
fetch = (url) ->
  request = js.new XMLHttpRequest
  request\open 'GET', url, false
  request\send js.null

  assert request.status == 200, "unexpected status code: #{request.status}"
  request.responseText

class WebStore
  new: (opts = {}) =>
    if MODE == 'CLIENT'
      origin = location.origin
      opts.host or= origin
    opts.verbose or= false

    if not opts.verbose
      @log = ->

    -- ensure host ends without a slash
    @host = opts.host\match '^(.-)/?$'
    @log "connecting to '#{@host}'..."

  log: (...) =>
    print "[DB]", ...

  -- fileders
  list_fileders_in: (path='') =>
    coroutine.wrap ->
      json = fetch "#{@host .. path}/?index: application/json"
      index = JSON\parse json
      for child in js.of index.children
        coroutine.yield child.path

  list_all_fileders: (path='') =>
    coroutine.wrap ->
      for path in @list_fileders_in path
        coroutine.yield path
        for p in @list_all_fileders path
          coroutine.yield p

  create_fileder: (parent, name) =>
    @log "creating fileder #{path}"
    error "not implemented"

  remove_fileder: (path) =>
    @log "removing fileder #{path}"
    error "not implemented"

  rename_fileder: (path, next_name) =>
    @log "renaming fileder #{path} -> '#{next_name}'"
    error "not implemented"

  move_fileder: (path, next_parent) =>
    @log "moving fileder #{path} -> #{next_parent}/"
    error "not implemented"

  -- facets
  list_facets: (path) =>
    coroutine.wrap ->
      json = fetch "#{@host .. path}/?index: application/json"
      index = JSON\parse json
      for facet in js.of index.facets
        coroutine.yield facet.name, facet.type
        -- @TODO: this doesn't belong here!
        if facet.type\match 'text/moonscript'
          coroutine.yield facet.name, facet.type\gsub 'text/moonscript', 'text/lua'

  load_facet: (path, name, type) =>
    fetch "#{@host .. path}/#{name}: #{type}"

  create_facet: (path, name, type, blob) =>
    @log "creating facet #{path} | #{name}: #{type}"
    error "not implemented"

  remove_facet: (path, name, type) =>
    @log "removing facet #{path} | #{name}: #{type}"
    error "not implemented"

  rename_facet: (path, name, type, next_name) =>
    @log "renaming facet #{path} | #{name}: #{type} -> #{next_name}"
    error "not implemented"

  update_facet: (path, name, type, blob) =>
    @log "updating facet #{path} | #{name}: #{type}"
    error "not implemented"

{
  :WebStore
}
