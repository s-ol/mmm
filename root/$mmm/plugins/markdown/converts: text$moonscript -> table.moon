markdown = if MODE == 'SERVER'
  success, discount = pcall require, 'discount'
  assert success, "couldn't require 'discount'"

  (md) ->
    res = assert discount.compile md, 'githubtags', 'fencedcode'
    res.body
else
  assert window and window.marked, "marked.js not found"

  o = do
    mkobj = window\eval "(function () { return {}; })"
    (tbl) ->
      with obj = mkobj!
        for k,v in pairs(tbl)
          obj[k] = v

  trim = (str) -> str\match '^ *(..-) *$'

  window.marked\setOptions o {
    gfm: true
    smartypants: true
    langPrefix: 'lang-'
    highlight: (code, lang) =>
      code = trim code
      result = if lang and #lang > 0
        window.hljs\highlight lang, code, true
      else
        window.hljs\highlightAuto code

      result.value
  }

  window\marked

assert markdown, "no markdown implementation found"

{
  {
    inp: 'text/markdown'
    out: 'text/html+frag'
    cost: 1
    transform: (md) => "<div class=\"markdown\">#{markdown md}</div>"
  }
  {
    inp: 'text/markdown%+sidenotes'
    out: 'text/html+frag'
    cost: 1
    transform: (md) => "<div class=\"markdown sidenote-container\">#{markdown md}</div>"
  }
  {
    inp: 'text/markdown%+wide'
    out: 'text/html+frag'
    cost: 1
    transform: (md) => "<div class=\"markdown wide\">#{markdown md}</div>"
  }
  {
    inp: 'text/markdown%+span'
    out: 'text/html+frag'
    cost: 1
    transform: (source) =>
      html = markdown source
      html = html\gsub '^%s*<p>%s*', '<span>'
      html = html\gsub '%s*</p>%s*$', '</span>'
      html
  }
}
