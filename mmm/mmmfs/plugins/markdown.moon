markdown = if MODE == 'SERVER'
  success, discount = pcall require, 'discount'
  assert success, "couldn't require 'discount'"

  (md) ->
    res = assert discount.compile md, 'githubtags'
    res.body
else
  assert window and window.marked, "marked.js not found"
  window\marked

assert markdown, "no markdown implementation found"

{
  converts: {
    {
      inp: 'text/markdown'
      out: 'text/html+frag'
      cost: 1
      transform: (md) => "<div class=\"markdown\">#{markdown md}</div>"
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
}
