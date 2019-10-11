require = relative ..., 0

class Store
  new: (opts) =>
    opts.verbose or= false

    if not opts.verbose
      @log = ->

  list_fileders_in: => error "not implemented"

  list_all_fileders: (path='') =>
    coroutine.wrap ->
      for path in @list_fileders_in path
        coroutine.yield path
        for p in @list_all_fileders path
          coroutine.yield p

  get_index: (path='', depth=1) =>
    if depth == 0
      return path

    {
      :path
      facets: [{:name, :type} for name, type in @list_facets path]
      children: [@get_index child, depth - 1 for child in @list_fileders_in path]
    }

  close: =>

  log: (...) =>
    print "[#{@@__name}]", ...

-- instantiate a store from a CLI arg
-- e.g.: sql, fs:/path/to/root, sql:MEMORY, sql:db.sqlite3
get_store = (args='sql', opts={verbose: true}) ->
  type, arg = args\match '(%w+):(.*)'
  type = args unless type

  switch type\lower!
    when 'sql'
      import SQLStore from require '.sql'

      if arg == 'MEMORY'
        opts.memory = true
      else
        opts.file = arg

      SQLStore opts

    when 'fs'
      import FSStore from require '.fs'

      opts.root = arg

      FSStore opts

    else
      warn "unknown or missing value for STORE: valid types values are sql, fs"
      os.exit 1

{
  :Store
  :get_store
}
