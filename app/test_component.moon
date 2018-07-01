{ :document, Node } = js.global

import div, h1, ul, li, pre from require './html.moon'

test_group = (name) ->
  list = ul!
  root = div (h1 name), list
  root, (name, test) ->
    ok, err = pcall test
    list\appendChild li if ok
      "passed '#{name}'"
    else
      "failed '#{name}'", pre err

node, run_test = test_group 'component.moon'
document.body\appendChild node

local ReactiveVar, ReactiveElement
run_test "exports ReactiveVar, ReactiveElement", ->
  import ReactiveVar, ReactiveElement from require './component.moon'
  assert ReactiveVar, "ReactiveVar not exported"
  assert ReactiveElement, "ReactiveElement not exported"

run_test "exports asnode helper", ->
  import asnode from require './component.moon'
  assert 'function' == (type asnode), "asnode not exported"

run_test "exports append helper", ->
  import append from require './component.moon'
  assert 'function' == (type append), "append not exported"

run_test "exports text helper", ->
  import text from require './component.moon'
  assert 'function' == (type text), "text not exported"

  node = text 'a test string'
  assert (js.instanceof node, js.global.Node), "expected text to generate a Node"
  assert node.data == 'a test string', "expected text to store the string"

run_test "text joins multiple arguments", ->
  import text from require './component.moon'

  node = text 'a', 'test', 'string'
  assert node.data == 'a test string', "expected text to join arguments with spaces"

node, run_test = test_group 'ReactiveVar'
document.body\appendChild node

run_test "stores a value", ->
  reactive = ReactiveVar 'test'
  assert 'test' == reactive\get!, "expected x to be 'test'"

run_test "propagates updates", ->
  local done

  reactive = ReactiveVar 'test'
  reactive\subscribe coroutine.wrap (next) ->
    assert next == 'toast', "expected next to be 'toast'"
    assert coroutine.yield! == 'cheese', "expected next to be 'cheese'"
    done = true

  reactive\set 'toast'
  assert 'toast' == reactive\get!, "expected #get to return 'toast'"
  reactive\set 'cheese'
  assert done, "expected to reach the end"

run_test "passed old value as well", ->
  local done

  reactive = ReactiveVar 1
  reactive\subscribe coroutine.wrap (next, last) ->
    assert last == 1, "expected last:1 to be 1"
    next, last = coroutine.yield!
    assert last == 2, "expected last:2 to be 2"
    done = true

  reactive\set 2
  reactive\set 3
  assert done, "expected to reach the end"

run_test "#subscribe returns function to unsubscribe", ->
  calls = 0

  reactive = ReactiveVar 1
  unsub = reactive\subscribe coroutine.wrap () ->
    calls += 1
    coroutine.yield!
    calls += 1
    coroutine.yield!
    calls += 1

  assert 'function' == (type unsub), "expected to receive a function"

  reactive\set 2
  reactive\set 3
  assert calls == 2, "wat"

  unsub!
  reactive\set 4
  assert calls == 2, "expected to stop receiving updates"

run_test "tracks multiple subscriptions at once", ->
  reactive = ReactiveVar 'test'
  unsub = reactive\subscribe coroutine.wrap (next) ->
    assert next == 'toast', "expected next to be toast"
    next = coroutine.yield!
    assert next == 'cheese', "expected next to be cheese"
    coroutine.yield!
    error "expected not to get here"

  reactive\set 'toast'

  local done
  reactive\subscribe coroutine.wrap (next) ->
    assert next == 'cheese', "expected next to be cheese"
    next = coroutine.yield!
    assert next == 'test', "expected next to be test"
    done = true

  reactive\set 'cheese'
  unsub!
  reactive\set 'test'
  assert done, "expected to reach the end"

node, run_test = test_group 'ReactiveElement'
document.body\appendChild node

run_test "creates a HTML element", ->
  elem = ReactiveElement 'span'
  assert elem.node and elem.node.localName == 'span', "expected Node to be a <span>"

run_test "sets attributes from a table arg", ->
  elem = ReactiveElement 'span', class: 'never'
  assert elem.node.class == 'never', "expected class to be 'never'"

run_test "appends Nodes from arguments", ->
  e_div, e_pre = div!, pre!
  elem = ReactiveElement 'span', e_div, e_pre
  assert elem.node.firstElementChild == e_div, "expected div to be the first child of elem"
  assert elem.node.lastElementChild == e_pre, "expected pre to be the last child of elem"

run_test "can append ReactiveElements and text", ->
  e_div = ReactiveElement 'div'
  elem = ReactiveElement 'div', e_div, 'testtext'
  assert elem.node.firstElementChild == e_div.node, "expected div to be the first child of elem"
  assert elem.node.lastChild.data == 'testtext', "expected last child of elem to be 'testtext'"

run_test "accepts attributes after children", ->
  e_div = div!
  elem = ReactiveElement 'div', e_div, class: 'test'
  assert elem.node.firstElementChild == e_div, "expected div to be the first child of elem"
  assert elem.node.class == 'test', "expected class to be 'test'"

run_test "allows mixing attributes and children in a single table", ->
  e_div, e_pre = div!, pre!
  elem = ReactiveElement 'div', { class: 'test', e_div, e_pre }
  assert elem.node.firstElementChild == e_div, "expected div to be the first child of elem"
  assert elem.node.lastElementChild == e_pre, "expected pre to be the last child of elem"
  assert elem.node.class == 'test', "expected class to be 'test'"

run_test "can unwrap and track attributes from ReactiveVars", ->
  klass = ReactiveVar 'test'
  elem = ReactiveElement 'div', class: klass
  assert elem.node.class == 'test', "expected class to be 'test'"
  klass\set 'toast'
  assert elem.node.class == 'toast', "expected class to be 'toast'"

run_test "can unwrap and track children from ReactiveVars", ->
  child = ReactiveVar h1 'test'
  elem = ReactiveElement 'div', child, pre 'fixed'
  assert elem.node.firstElementChild.localName == 'h1', "expected first child to be h1"
  assert elem.node.childElementCount == 2, "expected node to have two children"
  child\set div 'toast'
  assert elem.node.firstElementChild.localName == 'div', "expected first child to be div"
  assert elem.node.childElementCount == 2, "expected node to have two children"

run_test "warns when appending a string from a ReactiveVar", ->
  import text from require './component.moon'
  export print
  _print = print

  calls = 0
  print = (msg) -> calls += 1 if 'WARN: string' == msg\sub 1, 12

  str = ReactiveVar 'test'
  elem = ReactiveElement 'div', str
  assert calls == 1, "expected to print warning"

  str\set 'string too'
  assert calls == 2, "expected to print warning again"

  str\set text 'this is text'
  assert calls == 2, "expected not to print warning with text node"

  print = _print
