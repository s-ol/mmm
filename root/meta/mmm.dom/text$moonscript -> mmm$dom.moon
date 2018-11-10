import article, h1, h2, p, a, div, pre, code from require 'mmm.dom'
import lua, moonscript from (require 'mmm.highlighting').languages

mmmdom = -> code 'mmm.dom'

source = do
  (moon_src, lua_src, demo=true) ->
    the_code = pre (moonscript moon_src), (lua lua_src), class: 'dual-code'

    return the_code unless demo

    example = assert load lua_src
    div the_code, div example!, class: 'example'

article {
  h1 mmmdom!
  p mmmdom!, " is a lightweight DSL for creating HTML documents in Lua and Moonscript."

  p do
    fengari = a "fengari.io", href: '//fengari.io'

    "The same API is supported both on the server / in native Lua, where it outputs an HTML string,
    as well as on the client (using ", fengari, "), where it dynamically creates DOM Nodes that can
    be further manipulated using Lua or JavaScript. The API behaves exactly the same way in both modes
    so that you can write code once that works both for rendering offline/serverside and in the browser.
    This enables you to build websites and applications with dynamic content as well as perfect static
    views for clients with JS disabled and SEO."

  h2 "API"
  p "Begin by requiring ", mmmdom!, ". The module returns a 'magic table' that allows you to instantiate
    HTML elements of any type. Compare the usage in Lua and Moonscript:"

  source [[
import div, h1, p, a from require 'mmm.dom'

-- or just use dom.div etc. if you want to keep your
-- namespace clean, they are cached automatically

dom = require 'mmm.dom'
  ]], [[
local dom = require 'mmm.dom'

local div, h1, p, a = dom.div, dom.h1, dom.p, dom.a

-- or just use dom.div etc. if you want to keep your
-- namespace clean, they are cached automatically
  ]], false

  p "Each of these constructor functions can now be used to instantiate elements of the specified type.
    In the simplest case, you may want to a simple element with no attributes or children, for example a ",
    (code '<br />'), " line break tag:"

  source [[
import br from require 'mmm.dom'

br!
  ]], [[
local dom = require 'mmm.dom'

return dom.br()
  ]], false

  p "You can pass any number of children as arguments when you create an element. They will be joined without spaces:"

  source [[
import h3, i, code from require 'mmm.dom'

h3 "this is a ",
  (i 'headline'),
  " with some ",
  code 'rich text'
]], [[
local d = require 'mmm.dom'

return d.h3(
  "this is a ",
  d.i 'headline',
  " with some ",
  d.code 'rich text'
)
  ]]

  p "As you can see, ", mmmdom!, " can be used quite comfortably both in Lua and Moonscript."
  p "As you build bigger structures, you may find that constructing HTML trees via argument lists can get a bit
    confusing (especially with Moonscript and indentation rules).
    Because of this ", mmmdom!, " also supports passing a table with children in the integer keys 1, 2, ...
    This is particularily useful when you make use of Lua's shorthand for calling functions with single arguments:"

  source [[
import article, h3, span, div, i, p from require 'mmm.dom'

article {
  h3 "This is a headline with ", i "cursive text"
  p {
    "The content goes ",
    i "here."
  }
  p "more paragraphs can be added as well, of course."
}
    ]], [[
local dom = require 'mmm.dom'
local article, h3, span, div, i, p = dom.article, dom.h3, dom.span, dom.div, dom.i, dom.p

return article{
  h3{ "This is a headline with ", i "cursive text" },
  p{
    "The content goes ",
    i"here."
  },
  p"more paragraphs can be added as well, of course."
}
  ]]

  p "Of course ", mmmdom!, " also allows you to set attributes on elements."
  p "When you are using a constructor using the single-table approach,
    all string keys set on the table are considered attributes and set on the element:"

  source [[
import div from require 'mmm.dom'

div {
  id: 'my_div',
  class: 'shadow',
  "This is div matches the CSS selector `div#my_div.shadow`"
}
    ]], [[
local div = require('mmm.dom').div

return div{
  id = 'my_div',
  class = 'shadow',
  "This is div matches the CSS selector `div#my_div.shadow`"
}
  ]]

  p "When you are passing multiple arguments, you can attach the attributes in a table
    as the last argument. This works very well with Moonscript syntax."

  p "In general attribute values need to be strings or numbers to be rendered correctly both
    on client on server. The only exception is the ", (code 'style'), " attribute, which,
    if it is passed as a table, will be expanded into a valid CSS string:"

  source [[
import div from require 'mmm.dom'

div "red div with white text", style: {
  background: 'red',
  color: '#ffffff',
}
    ]], [[
local div = require('mmm.dom').div

return div(
  "red div with white text",
  {
    style = {
      background = 'red',
      color = '#ffffff',
    }
  }
)
  ]]
}
