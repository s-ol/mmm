require = relative ..., 1
import Store from require '.'
{ :location, :XMLHttpRequest, :JSON, :Object, :Array } = js.global

-- split filename into dirname + basename
dir_base = (path) ->
  dir, base = path\match '(.-)([^/]-)$'
  if dir and #dir > 0
    dir = dir\sub 1, #dir - 1

  dir, base

req = (method, url, content=js.null) ->
  if not url
    url = method
    method = 'GET'

  request = js.new XMLHttpRequest
  request\open method, url, false
  request\send content

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

  (string) -> fix JSON\parse string

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
    json = req "#{@host .. path}/#{pseudo}: text/json"
    parse_json json

  -- fileders
  list_fileders_in: (path='') =>
    coroutine.wrap ->
      json = req "#{@host .. path}/?index: text/json"
      index = parse_json json
      for child in js.of index.children
        coroutine.yield child.path

  create_fileder: (parent, name) =>
    path = "#{parent}/#{name}"
    @log "creating fileder #{path}"
    req 'POST', "#{@host .. path}/"

  remove_fileder: (path) =>
    @log "removing fileder #{path}"
    req 'DELETE', "#{@host .. path}/"

  rename_fileder: (path, next_name) =>
    @log "renaming fileder #{path} -> '#{next_name}'"
    error "not implemented"

  move_fileder: (path, next_parent) =>
    @log "moving fileder #{path} -> #{next_parent}/"
    error "not implemented"

  swap_fileders: (parent, child_a, child_b) =>
    req 'PUT', "#{@host .. parent}/", "swap\n#{child_a}\n#{child_b}"

  -- facets
  list_facets: (path) =>
    coroutine.wrap ->
      json = req "#{@host .. path}/?index: text/json"
      index = JSON\parse json
      for facet in js.of index.facets
        coroutine.yield facet.name, facet.type

  load_facet: (path, name, type) =>
    @log "loading facet #{path} #{name}: #{type}"
    req "#{@host .. path}/#{name}: #{type}"

  create_facet: (path, name, type, blob) =>
    @log "creating facet #{path} | #{name}: #{type}"
    req 'POST', "#{@host .. path}/#{name}: #{type}", blob

  remove_facet: (path, name, type) =>
    @log "removing facet #{path} | #{name}: #{type}"
    req 'DELETE', "#{@host .. path}/#{name}: #{type}"

  rename_facet: (path, name, type, next_name) =>
    @log "renaming facet #{path} | #{name}: #{type} -> #{next_name}"
    blob = assert "no such facet", @load_facet path, name, type
    @create_facet path, next_name, type, blob
    @remove_facet path, name, type

  update_facet: (path, name, type, blob) =>
    @log "updating facet #{path} | #{name}: #{type}"
    req 'PUT', "#{@host .. path}/#{name}: #{type}", blob

{
  :WebStore
}
