import code from require 'mmm.dom'

trim = (str) -> str\match '^ *(..-) *$'

highlight = if MODE == 'SERVER'
  (lang, str) ->
    assert str, 'no string to highlight'
    code (trim str), class: "hljs lang-#{lang}"
else
  (lang, str) ->
    assert str, 'no string to highlight'

    if not window.hljs\getLanguage lang
      lang = 'markdown'
    
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
