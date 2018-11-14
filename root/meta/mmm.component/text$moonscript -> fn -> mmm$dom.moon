import article, section, h1, h2, h3, p, a, b, div, ul, li, pre, code from require 'mmm.dom'
import tohtml from require 'mmm.component'
import lua, moonscript from (require 'mmm.highlighting').languages

mmmcomp = -> code 'mmm.component'

source = do
  (moon_src, lua_src, demo=true) ->
    the_code = pre (moonscript moon_src), (lua lua_src), class: 'dual-code'

    return the_code unless demo

    if demo == true
      example = assert load lua_src
      demo = tohtml example!

    div the_code, div demo, class: 'example'

raw_find = (fileder, key_pat) ->
  for key, val in pairs fileder.facets
    return val if key\tostring!\match key_pat

=>
  example = (name) ->
    for child in *@children
      if name == child\gett 'name: alpha'
        moon_src = child\get 'text/moonscript.*'
        lua_src = child\get 'text/lua.*'
        dom = child\gett 'mmm/dom'

        return source moon_src, lua_src, dom

  article {
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

    p do
      repo = a 'here', href: '//github.com/s-ol/mmm'

      "You will also find that most interactive UI on this page, including the navigation and browsing system,
      have been built using ", mmmcomp!, " as well. The source code is available ", repo, "."

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

        p "Each of the node creation functions behave just like the counterparts in ", (code 'mmm.dom'), ", except for
          the fact that each child or attribute value can also be provided as a ", rvar!, " instance and will be
          unwrapped and tracked automatically:"

        example 'text_input'

        p "Note that when you want to pass non-elements (e.g. strings or numbers) to an element as children, they will
          automatically be escaped using ", (code 'text'), ", but this ", (b "breaks reactivity"), ", so you should ",
          (code ':map(text)'), " these values before passing them to an element, like this:"

        example 'simple_counter'
      }
  }
