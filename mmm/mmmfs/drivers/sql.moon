sqlite = require 'sqlite3'
root = os.tmpname!

class SQLStore
  new: (opts = {}) =>
    opts.file or= 'db.sqlite3'
    opts.verbose or= false
    opts.memory or= false

    if not opts.verbose
      @log = ->

    if opts.memory
      @log "opening in-memory DB..."
      @db = sqlite.open_memory!
    else
      @log "opening '#{opts.file}'..."
      @db = sqlite.open opts.file

    assert @db\exec [[
      PRAGMA foreign_keys = ON;
      PRAGMA case_sensitive_like = ON;
      CREATE TABLE IF NOT EXISTS fileder (
        id INTEGER NOT NULL PRIMARY KEY,
        path TEXT NOT NULL UNIQUE,
        parent TEXT REFERENCES fileder(path)
                      ON DELETE CASCADE
                      ON UPDATE CASCADE
      );
      INSERT OR IGNORE INTO fileder (path, parent) VALUES ("", NULL);

      CREATE TABLE IF NOT EXISTS facet (
        fileder_id INTEGER NOT NULL
                   REFERENCES fileder
                     ON UPDATE CASCADE
                     ON DELETE CASCADE,
        name TEXT NOT NULL,
        type TEXT NOT NULL,
        value BLOB NOT NULL,
        PRIMARY KEY (fileder_id, name, type)
      );
      CREATE INDEX IF NOT EXISTS facet_fileder_id ON facet(fileder_id);
      CREATE INDEX IF NOT EXISTS facet_name ON facet(name);
    ]]

  log: (...) =>
    print "[DB]", ...

  close: =>
    @db\close!

  fetch: (q, ...) =>
    stmt = assert @db\prepare q
    stmt\bind ...  if 0 < select '#', ...
    stmt\irows!

  fetch_one: (q, ...) =>
    stmt = assert @db\prepare q
    stmt\bind ... if 0 < select '#', ...
    stmt\first_irow!

  exec: (q, ...) =>
    stmt = assert @db\prepare q
    stmt\bind ...  if 0 < select '#', ...
    res = assert stmt\exec!

  -- fileders
  list_fileders_in: (path='') =>
    coroutine.wrap ->
      for { path } in @fetch 'SELECT path
                              FROM fileder WHERE parent IS ?', path
        coroutine.yield path

  list_all_fileders: (path='') =>
    coroutine.wrap ->
      for path in @list_fileders_in path
        coroutine.yield path
        for p in @list_all_fileders path
          coroutine.yield p

  create_fileder: (parent, name) =>
    path = "#{parent}/#{name}"

    @log "creating fileder #{path}"
    @exec 'INSERT INTO fileder (path, parent)
           VALUES (:path, :parent)',
          { :path, :parent }

    changes = @fetch_one 'SELECT changes()'
    assert changes[1] == 1, "couldn't create fileder - parent missing?"
    path

  remove_fileder: (path) =>
    @log "removing fileder #{path}"
    @exec 'DELETE FROM fileder
           WHERE path LIKE :path || "/%"
              OR path = :path', path

  rename_fileder: (path, next_name) =>
    @log "renaming fileder #{path} -> '#{next_name}'"
    error 'not implemented'

    @exec 'UPDATE fileder
           SET path = parent || "/" || :next_name
           WHERE path = :path',
          { :path, :next_name }

    -- @TODO: rename all children, child-children...

  move_fileder: (path, next_parent) =>
    @log "moving fileder #{path} -> #{next_parent}/"
    error 'not implemented'

    -- @TODO: remove all children, child-children...

  -- facets
  list_facets: (path) =>
    coroutine.wrap ->
      for { name, type } in @fetch 'SELECT facet.name, facet.type
                                    FROM facet
                                    INNER JOIN fileder ON facet.fileder_id = fileder.id
                                    WHERE fileder.path = ?', path
        coroutine.yield name, type

  load_facet: (path, name, type) =>
    v = @fetch_one 'SELECT facet.value
                    FROM facet
                    INNER JOIN fileder ON facet.fileder_id = fileder.id
                    WHERE fileder.path = :path
                      AND facet.name = :name
                      AND facet.type = :type',
                   { :path, :name, :type }
    v and v[1]

  create_facet: (path, name, type, blob) =>
    @log "creating facet #{path} | #{name}: #{type}"
    @exec 'INSERT INTO facet (fileder_id, name, type, value)
           SELECT id, :name, :type, :blob
           FROM fileder
           WHERE fileder.path = :path',
          { :path, :name, :type, :blob }

    changes = @fetch_one 'SELECT changes()'
    assert changes[1] == 1, "couldn't create facet - fileder missing?"

  remove_facet: (path, name, type) =>
    @log "removing facet #{path} | #{name}: #{type}"
    @exec 'DELETE FROM facet
           WHERE name = :name
             AND type = :type
             AND fileder_id = (SELECT id FROM fileder WHERE path = :path)',
          { :path, :name, :type }

    changes = @fetch_one 'SELECT changes()'
    assert changes[1] == 1, "no such facet"

  rename_facet: (path, name, type, next_name) =>
    @log "renaming facet #{path} | #{name}: #{type} -> #{next_name}"
    @exec 'UPDATE facet
           SET name = :next_name
           WHERE name = :name
             AND type = :type
             AND fileder_id = (SELECT id FROM fileder WHERE path = :path)',
          { :path, :name, :next_name, :type }

    changes = @fetch_one 'SELECT changes()'
    assert changes[1] == 1, "no such facet"

  update_facet: (path, name, type, blob) =>
    @log "updating facet #{path} | #{name}: #{type}"
    @exec 'UPDATE facet
           SET value = :blob
           WHERE facet.name = :name
             AND facet.type = :type
             AND facet.fileder_id = (SELECT id FROM fileder WHERE path = :path)',
          { :path, :name, :type, :blob }

    changes = @fetch_one 'SELECT changes()'
    assert changes[1] == 1, "no such facet"

{
  :SQLStore
}
