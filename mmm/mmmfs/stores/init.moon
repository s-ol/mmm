require = relative ..., 0

-- instantiate a store from a CLI arg
-- e.g.: sql, lfs:/path/to/root, sql:MEMORY, sql:db.sqlite3
get_store = (args='sql', opts={verbose: true}) ->
  type, arg = args\match '(%w+):(.*)'
  type = arg unless type

  switch type\lower!
    when 'sql'
      import SQLStore from require '.sql'

      if arg == 'MEMORY'
        opts.memory = true
      else
        opts.name = arg

      SQLStore opts

    when 'lfs'
      import LFSStore from require '.lfs'

      opts.root = arg

      LFSStore opts

    else
      warn "unknown or missing value for STORE: valid types values are sql, lfs"
      os.exit 1

{
  :get_store
}
