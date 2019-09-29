sqlite = require 'sqlite3'

class TreeStore
  new: (name='db.sqlite3') =>
    @db = if name then sqlite.open name else sqlite.open_memory!

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
  list_fileders_in: (path) =>
    coroutine.wrap ->
      for { path } in @fetch 'SELECT path
                              FROM fileder WHERE parent IS ?', path
        coroutine.yield path

  list_all_fileders: (path) =>
    coroutine.wrap ->
      for path in @list_fileders_in path
        coroutine.yield path
        for p in @list_all_fileders path
          coroutine.yield p

  create_fileder: (parent, name) =>
    @exec 'INSERT INTO fileder (path, parent)
           VALUES (IFNULL(:parent, "") || "/" || :name, :parent)',
          { :parent, :name }

    changes = @fetch_one 'SELECT changes()'
    assert changes[1] == 1, "couldn't create fileder - parent missing?"

  remove_fileder: (path) =>
    @exec 'DELETE FROM fileder
           WHERE path LIKE :path || "/%"
              OR path = :path', path

  rename_fileder: (path, next_name) =>
    error 'not implemented'

    @exec 'UPDATE fileder
           SET path = IFNULL(parent, "") || "/" || :next_name
           WHERE path = :path',
          { :path, :next_name }

    -- @TODO: rename all children, child-children...

  move_fileder: (path, new_parent) =>
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
    @exec 'INSERT INTO facet (fileder_id, name, type, value)
           SELECT id, :name, :type, :blob
           FROM fileder
           WHERE fileder.path = :path',
          { :path, :name, :type, :blob }

    changes = @fetch_one 'SELECT changes()'
    assert changes[1] == 1, "couldn't create facet - fileder missing?"

  remove_facet: (path, name, type) =>
    @exec 'DELETE FROM facet
           WHERE name = :name
             AND type = :type
             AND fileder_id = (SELECT id FROM fileder WHERE path = :path)',
          { :path, :name, :type }

    changes = @fetch_one 'SELECT changes()'
    assert changes[1] == 1, "no such facet"

  rename_facet: (path, name, type, next_name) =>
    @exec 'UPDATE facet
           SET name = :next_name
           WHERE name = :name
             AND type = :type
             AND fileder_id = (SELECT id FROM fileder WHERE path = :path)',
          { :path, :name, :next_name, :type }

    changes = @fetch_one 'SELECT changes()'
    assert changes[1] == 1, "no such facet"

  update_facet: (path, name, type, blob) =>
    @exec 'UPDATE facet
           SET value = :blob
           WHERE facet.name = :name
             AND facet.type = :type
             AND facet.fileder_id = (SELECT id FROM fileder WHERE path = :path)',
          { :path, :name, :type, :blob }

    changes = @fetch_one 'SELECT changes()'
    assert changes[1] == 1, "no such facet"

load_tree = (file='root.zip') ->
  archive = zip.open file

  fileders = setmetatable {},
    __index: (path) =>
      with val = Fileder {}
        .path = path
        rawset @, path, val

  fileders['/root'].facets['name: alpha'] = -> 'root'

  for i = 1, #archive
    { :name, :size } = archive\stat i

    path, facet = dir_base "/#{name}"
    parent, name = dir_base path

    key = load_facet facet

    this = fileders[path]
    this.facets['name: alpha'] = -> name
    this.facets[key] = ->
      file = archive\open i
      with file\read size
        file\close!

    table_add fileders[parent].children, this

  fileders['/root']

{
  :TreeStore,
  load_tree,
}
