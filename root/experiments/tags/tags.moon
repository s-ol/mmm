join = (tbl, sep) ->
  ret = ''
  for tag in pairs tbl
    ret ..= (tostring tag) .. sep
  ret

handlers = {
  add: {}
  rmv: {}
}

class Node
  new: (@name) =>
    @tags = {}

  inspect: =>
    "#{@name}: [#{join @tags, ' '}]"

  has: (tag) => @tags[tag]
  add: (tag) => @tags[tag] = tag
  rmv: (tag) => @tags[tag] = nil

any = -> true
literal = (def) -> (val) -> def == val
oneof   = (defs) -> (val) ->
  for def in *defs
    return true if def == val
  false
has = (tag) -> (node) -> node\has tag

add_tag = (node, tag) ->
  return if node\has tag
  node\add tag
  for hand, _ in pairs handlers.add
    hand\match node, tag

rmv_tag = (node, tag) ->
  return if not node\has tag
  node\rmv tag
  for hand, _ in pairs handlers.rmv
    hand\match node, tag

class Handler
  new: (@rule, @action, match, @func) =>
    @args = for arg in *match
      if 'string' == type arg
        literal arg
      elseif 'table' == type arg
        oneof arg
      else
        arg

  match: (...) =>
    supplied = { ... }
    assert #supplied == #@args, 'length of arguments doesnt match'
    for i = 1, #supplied
      return false if not @args[i] supplied[i]

    @.func @rule, ...

  name: => "#{@rule.name}:#{@action}"

class Rule
  new: (@name="#{@@__name}") =>
    @owned_handlers = {}

  hook: (action, ...) =>
    handler = Handler @, action, ...
    table.insert @owned_handlers, handler
    handlers[action][handler] = handler

  destroy: =>
    for hand in *@owned_handlers
      handlers[hand.action][hand] = nil

class Hierarchy extends Rule
  new: (@parent, @child) =>
    super!

    -- when something is tagged with the child-tag, apply the parent tag
    @hook 'add', { any, @child }, (node) =>
      add_tag node, @parent

    -- when child tag is removed, remove parent tag
    @hook 'rmv', { any, @child }, (node) =>
      rmv_tag node, @parent

    -- when parent tag is removed, remove child tag
    @hook 'rmv', { any, @parent }, (node) =>
      rmv_tag node, @child

class Toggle extends Rule
  new: (@a, @b) =>
    super!

    either = { @a, @b }
    opposite = (tag) -> if tag == @a then @b else @a

    -- when a is added, remove b and vice-versa
    @hook 'add', { any, either }, (node, tag) =>
      rmv_tag node, opposite tag

    -- when a is removed, add b and vice-versa
    @hook 'rmv', { any, either }, (node, tag) =>
      add_tag node, opposite tag

class NamespacedToggle extends Rule
  new: (@ns, @a, @b) =>
    super!

    namespaced = has @ns
    either = { @a, @b }
    opposite = (tag) -> if tag == @a then @b else @a

    -- when node enters namespace, add default tag
    @hook 'add', { any, @ns }, (node) =>
      add_tag node, @a

    -- when node leaves namespace, remove tags
    @hook 'rmv', { any, @ns }, (node) =>
      rmv_tag node, @a
      rmv_tag node, @b

    -- when a is added, remove b and vice-versa
    @hook 'add', { namespaced, either }, (node, tag) =>
      rmv_tag node, opposite tag

    -- when a is removed, add b and vice-versa
    @hook 'rmv', { namespaced, either }, (node, tag) =>
      add_tag node, opposite tag

{
  :Node,
  :Rule,

  :any,
  :literal,
  :oneof,
  :has,
  :add_tag,
  :rmv_tag,

  :Hierarchy,
  :Toggle,
  :NamespacedToggle,
}
