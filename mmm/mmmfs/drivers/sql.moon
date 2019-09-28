sqlite = require 'sqlite3'

class TreeStore
  new: (name='db.sqlite3') =>
    @db = sqlite.open name

    assert @db\exec [[
      PRAGMA foreign_keys = ON;
      CREATE TABLE IF NOT EXISTS fileder (
        id INTEGER NOT NULL PRIMARY KEY,
        path TEXT NOT NULL UNIQUE,
        parent TEXT
      );
      CREATE TABLE IF NOT EXISTS facet (
        fileder_id INTEGER NOT NULL
                   REFERENCES fileder
                     ON UPDATE CASCADE
                     ON DELETE CASCADE,
        name TEXT,
        type TEXT,
        value BLOB,
        PRIMARY KEY (name, type)
      );
      CREATE INDEX IF NOT EXISTS facet_fileder_id ON facet(fileder_id);
      CREATE INDEX IF NOT EXISTS facet_name ON facet(name);
    ]]

  close: =>
    @db\close!

  fetch: (q, ...) =>
    stmt = assert @db\prepare q
    stmt\bind ...
    stmt\irows!

  fetch_one: (q, ...) =>
    stmt = assert @db\prepare q
    stmt\bind ...
    stmt\first_irow!

  exec: (q, ...) =>
    stmt = assert @db\prepare q
    stmt\bind ...
    assert stmt\exec!

  -- fileders
  list_fileders: (path, recursive=false) =>
    coroutine.wrap ->
      for { path } in @fetch 'SELECT path
                              FROM fileder WHERE parent = ?', path
        coroutine.yield path
        if recursive
          for p in @list_fileders path
            coroutine.yield p

  create_fileder: (parent, name) =>
    @exec 'INSERT INTO fileder (path, parent)
           VALUES (:path, :parent)',
          { path: "#{parent}/#{name}", :parent }

  remove_fileder: (path) =>
    @exec 'DELETE FROM fileder
           WHERE path = ?', path

  rename_fileder: (path, next_name) =>
    @exec 'UPDATE fileder
           SET path = CONCAT(parent, "/", :next_name)
           WHERE path = :path',
          { :path, :next_name }
    -- @TODO: rename all children, child-children...

  move_fileder: (path, new_path) =>
    error '@TODO: implement move_fileder'

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
    v[1]

  create_facet: (path, name, type, blob) =>
    @exec 'INSERT INTO facet (fileder_id, name, type, value)
           SELECT id, :name, :type, :blob
           FROM fileder
           WHERE fileder.path = :path',
          { :path, :name, :type, :blob }

  remove_facet: (path, name, type) =>
    @exec 'DELETE FROM facet
           WHERE name = :name
             AND type = :type
             AND fileder_id = (SELECT id FROM fileder WHERE path = :path)',
          { :path, :name, :type }

  rename_facet: (path, name, type, next_name) =>
    @exec 'UPDATE facet
           SET name = :next_name
           WHERE name = :name
             AND type = :type
             AND fileder_id = (SELECT id FROM fileder WHERE path = :path)',
          { :path, :name, :next_name, :type }

  update_facet: (path, name, type, blob) =>
    @exec 'UPDATE facet
           SET value = :blob
           WHERE facet.name = :name
             AND facet.type = :type
             AND facet.fileder_id = (SELECT id FROM fileder WHERE path = :path)',
          { :path, :name, :type, :blob }

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
