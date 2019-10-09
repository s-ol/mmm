sort2 = (a, b) ->
  {ax, ay}, {bx, by} = a, b
  "#{ax}//#{ay}" < "#{bx}//#{by}"

toseq = (iter) ->
  with v = [x for x in iter]
    table.sort v

toseq2 = (iter) ->
  with v = [{x, y} for x, y in iter]
    table.sort v, sort2

test_store = (ts) ->
  randomize false

  it "starts out empty", ->
    assert.are.same {}, toseq ts\list_fileders_in!
    assert.are.same {}, toseq ts\list_all_fileders!

  it "can't create fileders without missing parents", ->
    assert.has_error ->
      ts\create_fileder '/hello', 'world'

  it "can create root fileders", ->
    assert.are.same '/hello', ts\create_fileder '', 'hello'
    assert.are.same {'/hello'}, toseq ts\list_all_fileders!

  it "can create and list child fileders recursively", ->
    assert.are.same '/hello/world',
                    ts\create_fileder '/hello', 'world'
    assert.are.same '/hello/world/again',
                    ts\create_fileder '/hello/world', 'again'

    assert.are.same {'/hello', '/hello/world', '/hello/world/again'},
                    toseq ts\list_all_fileders!

  it "can list immediate children", ->
    assert.are.same {"/hello"}, toseq ts\list_fileders_in!
    assert.are.same {"/hello/world"}, toseq ts\list_fileders_in "/hello"
    assert.are.same {"/hello/world/again"}, toseq ts\list_fileders_in "/hello/world"

  describe "can create and list facets", ->
    ts\create_facet '/hello', 'name', 'alpha', 'hello'
    ts\create_facet '/hello/world', 'name', 'alpha', 'world'
    ts\create_facet '/hello/world', '', 'text/markdown', '# Helau World!'

    it "but can't create facet for nonexistant fileders", ->
      assert.has_error -> ts\create_facet '/hello/orldw', 'name', 'alpha', 'foo'

    it "but can't create facet without value", ->
      assert.has_error -> ts\create_facet '/hello/world', 'other', 'alpha', nil

    it "but can't create facet for duplicate keys", ->
      assert.has_error -> ts\create_facet '/hello/world', 'name', 'alpha', 'foo'

    assert.are.same {{'name', 'alpha'}}, toseq2 ts\list_facets '/hello'
    assert.are.same {{'', 'text/markdown'}, {'name', 'alpha'}},
                    toseq2 ts\list_facets '/hello/world'

  it "can load facets", ->
    assert.are.equal 'hello', ts\load_facet '/hello', 'name', 'alpha'
    assert.are.equal 'world', ts\load_facet '/hello/world', 'name', 'alpha'
    assert.are.equal '# Helau World!', ts\load_facet '/hello/world', '', 'text/markdown'
    assert.is_falsy ts\load_facet '/hello', 'nonexistant', 'facet'

  it "can rename facets", ->
    ts\rename_facet '/hello/world', 'name', 'alpha', 'gnome'
    assert.are.same {{'', 'text/markdown'}, {'gnome', 'alpha'}},
                    toseq2 ts\list_facets '/hello/world'
    assert.are.equal 'world', ts\load_facet '/hello/world', 'gnome', 'alpha'

  it "can update facets", ->
    ts\update_facet '/hello/world', '', 'text/markdown', '# Hello World!'
    assert.are.same {{'', 'text/markdown'}, {'gnome', 'alpha'}},
                    toseq2 ts\list_facets '/hello/world'
    assert.are.equal '# Hello World!', ts\load_facet '/hello/world', '', 'text/markdown'

  it "can remove facets", ->
    ts\remove_facet '/hello/world', 'gnome', 'alpha'
    assert.are.same {{'', 'text/markdown'}}, toseq2 ts\list_facets '/hello/world'

    assert.has_error -> ts\remove_facet '/hello/world', 'gnome', 'alpha'

  it "can delete fileders", ->
    ts\remove_fileder '/hello/world'
    assert.is_falsy ts\load_facet '/hello/world', 'gnome', 'alpha'
    assert.are.same {'/hello'}, toseq ts\list_all_fileders!

    ts\remove_fileder '/hello'
    assert.are.same {}, toseq ts\list_all_fileders!

describe "SQL spec", ->
  import SQLStore from require 'mmm.mmmfs.stores.sql'

  test_store SQLStore memory: true

describe "FS store", ->
  import FSStore from require 'mmm.mmmfs.stores.fs'

  lfs = require 'lfs'

  root = os.tmpname!

  setup ->
    assert os.remove root
    assert lfs.mkdir root

  test_store LFSStore :root

  teardown ->
    assert lfs.rmdir root
