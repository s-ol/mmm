import article, section, h1, h2, h3, p, a, div, ul, li, pre, code from require 'mmm.dom'
import tohtml from require 'mmm.component'
import lua, moonscript from (require 'mmm.highlighting').languages

mmmcomp = -> code 'mmm.component'

source = do
  (moon_src, lua_src, demo=true) ->
    the_code = pre (moonscript moon_src), (lua lua_src), class: 'dual-code'

    return the_code unless demo

    example = assert load lua_src
    div the_code, div (tohtml example!), class: 'example'

=> article {
  h1 mmmcomp!
  p mmmcomp!, " is a small and DOM-centric framework for reactive web interfaces."

  p do
    fengari = a "fengari.io", href: '//fengari.io'

    "Built for reactive UI, ", mmmcomp!, " is meant to run on the client using ", fengari, ".
    However, like ", (code 'mmm.dom'), ", the API is supported both on the client as well as
    on the server (were most reactive features have been omitted) so that static pre-rendered
    content can still be generated from the same code that powers the reactive interface."

  h2 "Examples"
  p "Feel free to read the documentation below, or take a look at the following examples using the ",
    (code 'mmmfs'), " inspect mode:"

  ul for child in *@children
    li a (child\gett 'name: alpha'), {
      href: child.path,
      onclick: (e) =>
        e\preventDefault!
        BROWSER\navigate child.path
    }

  h2 "Guide"
  p "Begin by requiring ", mmmcomp!, ". The module returns a table containing the following:"

  ul {
    li (code 'ReactiveVar'), ": class/constructor for reactive state variables.",
    li (code 'ReactiveElement'), ": class/constructor for reactive DOM elements. Rarely used directly."
    li (code 'elements'), ": 'magic table' containing constructors for ReactiveElements by tag name."
    li (code 'tohtml'), ": helper to convert from ReactiveElements to mmm/dom (DOM nodes / HTML strings)"
    li (code 'text'), ": helper to convert Lua strings to DOM Text Nodes."
    li (code 'get_or_create'), ": helper for rehydratable views."
  }

  section do
    rvar = -> code 'ReactiveVar'

    {
      id: 'ReactiveVar'

      h3 "Reactive Variables"
      p mmmcomp!, " is centered around the concept of Reactive Variables (", rvar!, "s).
        A ", rvar!, " is a container for a piece of application state that other pieces of code can
        subscribe to. These attached callbacks are invoked whenever the value changes."

      p "You can instantiate a ", rvar!, " via the constructor at any time. The constructor takes
        the initial variable as an argument, but if you omit it ", (code 'nil'), " will work fine as well.
        After instantiation, ", (code ':get()'), " and ", (code ':set(val)'), " will give access to the value:"

      source [[
import ReactiveVar from require 'mmm.component'

test = ReactiveVar 3
print test\get! -- prints '3'
test\set 4
print test\get! -- prints '4'
      ]], [[
local ReactiveVar = require 'mmm.component'.ReactiveVar

local test = ReactiveVar(3)
print(test:get()) -- prints '3'
test:set(4)
print(test:get()) -- prints '4'
      ]], false

      p "The value can also be changed using ", (code ':transform(fn)'), ", which is simply a shorthand for ",
        (code 'var:set(fn(var:get()))'), ":"

      source [[
import ReactiveVar from require 'mmm.component'

add_one = (n) -> n + 1
count = ReactiveVar 1

count\transform add_one
print test\get! -- prints '2'

count\transform add_one
print test\get! -- prints '3'
      ]], [[
local ReactiveVar = require 'mmm.component'.ReactiveVar

local function add_one(x) return x + 1 end
local count = ReactiveVar(1)

count:transform(add_one)
print(test:get()) -- prints '2'

count:transform(add_one)
print(test:get()) -- prints '3'
      ]], false

      p "Now, so far we haven't really seen anything useful - this is all just behaving like a normal variable.
        The ", (code ':subscribe(callback)'), " method is what makes ", rvar!, "s interesting: Whenever the value
        changes, the ", rvar!, " calls each of the registered handlers, passing the new as well as the previous value:"

      source [[
import ReactiveVar from require 'mmm.component'

add_one = (n) -> n + 1
count = ReactiveVar 1
count\subscribe (new, old) ->
  print "changing from #{old} to #{new}!"


count\transform add_one -- changing from 1 to 2
count\set "a string"    -- changing from 2 to a string
      ]], [[
local ReactiveVar = require 'mmm.component'.ReactiveVar

local function add_one(x) return x + 1 end
local count = ReactiveVar(1)
cout:subscribe(function(new old)
  print("changing from " .. old .. " to " .. new)
end)

count:transform(add_one) -- changing from 1 to 2
count:set("a string")    -- changing from 2 to a string
      ]], false

      p "This allows other code (such as ", (code 'ReactiveElement'), "s) to react to value changes and update
        themselves, as we will see in a minute. Often you will want to derive state from other state. To make this
        easy while keeping everything reactive, ", mmmcomp!, " includes the ", (code ':map(fn)'), " method."

      p (code ':map(fn)'), " applies the function ", (code 'fn'), " to the current value, just as ",
        (code ':transform(fn)'), " would, but it doesn't update the value itself - it rather returns a new ", rvar!,
        " instance that is already set up to update whenever the original one changes."

      source [[
import ReactiveVar from require 'mmm.component'

fruit = ReactiveVar "apple"
loud_fruit = fruit\map string.upper

print fruit\get!      -- prints 'apple'
print loud_fruit\get! -- prints 'APPLE'

fruit\set "orange"
print loud_fruit\get! -- prints 'ORANGE'
      ]], [[
local ReactiveVar = require 'mmm.component'.ReactiveVar

local fruit = ReactiveVar("apple")
local loud_fruit = fruit:map(string.upper)

print(fruit:get())      -- prints 'apple'
print(loud_fruit:get()) -- prints 'APPLE'

fruit:set("orange")
print(loud_fruit:get()) -- prints 'ORANGE'
      ]], false
    }

  section do
    relem = -> code 'ReactiveElement'
    rvar = -> code 'ReactiveVar'

    {
      id: 'ReactiveElement'

      h3 relem!, "s"
      p relem!, " is a wrapper around DOM elements that allows you to use ", rvar!, "s to specify attributes and
        children of the element. Internally it ", (code ':subscribe()'), "s to each of the ", rvar!, "s so that it can
        update whenever any of the values change."

      p relem!, "s can be instantiated using the ", relem!, " constructor, but usually you will want to use the
        shorthand functions that you can pull out of the ", (code 'elements'), " 'magic table', as they will make your
        code much more legible. This table provides functions for creating any HTML element based on it's name.
        The elements you use are automatically cached so you can either pull out only the ones you want to use into
        your local namespace or use the table itself."

      p "Each of these node creation functions accept any number of nodes or strings as arguments and will attach these
        as their children:"

      source [[
import elements from require 'mmm.component'
import h1, code from elements

h1 "Hello from ", code 'mmm.component'

-- or if you want to keep your namespace clean:
e = elements
e.h1 "Hello from ", e.code 'mmm.component'
      ]], [[
local elements = require'mmm.component'.elements
local h1, code = elements.h1, elements.code

h1("Hello from ", code 'mmm.component')

-- or if you want to keep your namespace clean:
local e = elements
return e.h1("Hello from ", e.code 'mmm.component')
        ]]

      source [[
import text, elements from require 'mmm.component'
import div, button from elements

count = ReactiveVar 0

div {
  button '-', onclick: () -> count\transform (c) -> c - 1
  " count is: "
  count\map (num) -> text num
  " "
  button '+', onclick: () -> count\transform (c) -> c + 1
}
      ]], [[
local comp = require 'mmm.component'
local div, button = comp.elements.div, comp.elements.button

local count = comp.ReactiveVar(0)

return div {
  button {
    '-',
    onclick = function () count:set(count:get() - 1) end
  },
  " count is: ",
  count:map(function (num) return comp.text(num) end),
  " ",
  button {
    '+',
    onclick = function () count:set(count:get() + 1) end
  },
}
        ]]

      source [[
import text, elements from require 'mmm.component'
import select, option from elements

color = ReactiveVar 'white'

div {
  div 'test', style: color\map (background) ->
    { padding: '1em', :background }

  select {
    onchange: (e) => color\set e.target.value

    option 'white'
    option 'red'
    option 'green'
  }
}
      ]], [[
local comp = require 'mmm.component'
local e = comp.elements

local color = comp.ReactiveVar 'red'

return e.div {
  e.div { 'test', style = color:map(function (bg)
    return { padding = '1em', background = bg }
  end) },
  e.select {
    onchange = function (_, e) color:set(e.target.value) end,

    e.option 'red',
    e.option 'green',
    e.option 'blue',
  },
}
        ]]
      }
}
