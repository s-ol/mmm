require = relative ..., 1
import Store from require '.'
{ :location, :XMLHttpRequest, :JSON, :Object, :Array } = js.global

-- split filename into dirname + basename
dir_base = (path) ->
  dir, base = path\match '(.-)([^/]-)$'
  if dir and #dir > 0
    dir = dir\sub 1, #dir - 1

  dir, base

fetch = (url) ->
  request = js.new XMLHttpRequest
  request\open 'GET', url, false
  request\send js.null

  assert request.status == 200, "unexpected status code: #{request.status}"
  request.responseText

parse_json = do
  fix = (val) ->
    switch type val
      when 'userdata'
        if Array\isArray val
          [fix x for x in js.of val]
        else
          {(fix e[0]), (fix e[1]) for e in js.of Object\entries(val)}
      else
        val

  (string) ->
    print fix JSON\parse string
    fix JSON\parse string

class WebStore extends Store
  new: (opts = {}) =>
    super opts

    if MODE == 'CLIENT'
      origin = location.origin
      opts.host or= origin

    -- ensure host ends without a slash
    @host = opts.host\match '^(.-)/?$'
    @log "connecting to '#{@host}'..."

  get_index: (path='', depth=1) =>
    pseudo = if depth > 1 or depth < 0 '?tree' else '?index'
    json = fetch "#{@host .. path}/#{pseudo}: application/json"
    parse_json json

  -- fileders
  list_fileders_in: (path='') =>
    coroutine.wrap ->
      json = fetch "#{@host .. path}/?index: application/json"
      index = parse_json json
      for child in js.of index.children
        coroutine.yield child.path

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
