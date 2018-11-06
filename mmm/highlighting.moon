import code from require 'mmm.dom'
local highlight

trim = (str) -> str\match '^ *(..-) *$'

if MODE == 'SERVER'
  highlight = (lang, str) ->
    assert str, 'no string to highlight'
    code (trim str), class: "hljs lang-#{lang}"
else
  highlight = (lang, str) ->
    assert str, 'no string to highlight'
    result = window.hljs\highlight lang, (trim str), true
    with code class: "hljs lang-#{lang}"
      .innerHTML = result.value

languages = setmetatable {}, __index: (name) =>
  with val = (str) -> highlight name, str
    @[name] = val

{
  :highlight
  :languages
}
