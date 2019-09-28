import TreeStore from require 'mmm.mmmfs.drivers.sql'
ts = TreeStore!

assert_seq1 = (expected, iter) ->
  tbl
  i = 0

  for x in iter
    i += 1
    assert expected[i] == x, "entry #{i}: '#{x}', expected '#{expected[i]}'!"

  assert i == #expected, "only #{i} entries found, expected #{#expected}"

assert_seq2 = (expected, iter) ->
  tbl
  i = 0

  for a, b in iter
    i += 1
    assert expected[i][1] == a, "entry #{i} a: '#{a}', expected '#{expected[i][1]}'!"
    assert expected[i][2] == b, "entry #{i} b: '#{b}', expected '#{expected[i][2]}'!"

  assert i == #expected, "only #{i} entries found, expected #{#expected}"

assert_seq1 {}, ts\list_fileders ''
assert_seq1 {}, ts\list_fileders '', true

ts\create_fileder '', 'hello'
ts\create_fileder '/hello', 'world'
assert_seq1 {'/hello', '/hello/world'}, ts\list_fileders '', true

ts\create_facet '/hello/world', '', 'text/markdown', '# Helau World!'
ts\create_facet '/hello/world', 'nome', 'alpha', 'world'

assert_seq2 {}, ts\list_facets '/hello'
assert_seq2 { {'', 'text/markdown'}, {'nome', 'alpha'} }, ts\list_facets '/hello/world'

ts\rename_facet '/hello/world', 'nome', 'alpha', 'name'
assert_seq2 { {'', 'text/markdown'}, {'name', 'alpha'} }, ts\list_facets '/hello/world'

assert ('# Helau World!' == ts\load_facet '/hello/world', '', 'text/markdown')
ts\update_facet '/hello/world', '', 'text/markdown', '# Hello World!'
assert ('# Hello World!' == ts\load_facet '/hello/world', '', 'text/markdown')

ts\remove_fileder '/hello/world'
ts\remove_fileder '/hello'

assert_seq2 {}, ts\list_facets '/hello/world'
assert_seq1 {}, ts\list_fileders '', true
