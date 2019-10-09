require = relative ..., 0

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
  :get_store
}
