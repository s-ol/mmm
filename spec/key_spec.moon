require 'spec.test_util'
package.loaded['mmm.mmmfs.conversion'] = {}
import Key from require 'mmm.mmmfs.fileder'

nt = (name, type) -> :name, :type

describe "Key", ->
  it "can be instantiated from a string", ->
    assert.are.same (nt '', 'type/only'), Key 'type/only'
    assert.are.same (nt '', 'type/only'), Key ':type/only'
    assert.are.same (nt '', 'the/type'), Key '   the/type'
    assert.are.same (nt '', 'the/type'), Key ':   the/type'
    assert.are.same (nt '', 'URL -> long/type -> some/type'), Key 'URL -> long/type -> some/type'

    assert.are.same (nt 'facet_name', 'some/type'), Key 'facet_name: some/type'
    assert.are.same (nt 'spacious_name', 'and/type'), Key 'spacious_name:    and/type'
    assert.are.same (nt 'name', 'URL -> long/type -> some/type'), Key 'name: URL -> long/type -> some/type'

  it "can be instantiated from two strings", ->
    assert.are.same (nt '', 'type/only'), Key '', 'type/only'
    assert.are.same (nt '', 'type/only'), Key nil, 'type/only'
    assert.are.same (nt 'facet_name', 'some/type'), Key 'facet_name', 'some/type'

    assert.are.same (nt 'name', 'URL -> long/type -> some/type'), Key 'name', 'URL -> long/type -> some/type'
    assert.are.same (nt '', 'URL -> long/type -> some/type'), Key '', 'URL -> long/type -> some/type'

    assert.are.same (nt 'spacious_name', '   and/type'), Key 'spacious_name', '   and/type'
    assert.are.same (nt '', '   the/type'), Key nil, '   the/type'

  it "can be instantiated from a table or instance", ->
    assert.are.same (nt '', 'type/only'), Key Key '', 'type/only'
    assert.are.same (nt '', 'type/only'), Key nt '', 'type/only'
    assert.are.same (nt '', 'type/only'), Key nt nil, 'type/only'

    assert.are.same (nt 'facet', 'the/type+extra'), Key Key 'facet', 'the/type+extra'
    assert.are.same (nt 'facet', 'the/type+extra'), Key nt 'facet', 'the/type+extra'

  it "throws an error otherwise", ->
    assert.has_error -> Key!
    assert.has_error -> Key true
    assert.has_error -> Key true, false
    assert.has_error -> Key 4
    assert.has_error -> Key 4, 5
    assert.has_error -> Key {}
    assert.has_error -> Key type: true

  it "tostring formats the key", ->
    assert.is.equal 'type/only', tostring Key 'type/only'
    assert.is.equal 'type/only', tostring Key '', 'type/only'
    assert.is.equal 'type/only', tostring Key ":   type/only"

    assert.is.equal 'facet: and/type+extra', tostring Key 'facet: and/type+extra'
    assert.is.equal 'facet: and/type+extra', tostring Key 'facet', 'and/type+extra'
    assert.is.equal 'facet: and/type+extra', tostring Key 'facet:   and/type+extra'

    assert.is.equal 'facet: and -> long -> type', tostring Key 'facet: and -> long -> type'
    assert.is.equal 'facet: and -> long -> type', tostring Key 'facet', 'and -> long -> type'
    assert.is.equal 'facet: and -> long -> type', tostring Key 'facet:   and -> long -> type'
