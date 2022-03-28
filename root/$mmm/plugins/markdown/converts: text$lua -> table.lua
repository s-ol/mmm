local markdown
if MODE == 'SERVER' then
  local success, discount = pcall(require, 'discount')
  assert(success, "couldn't require 'discount'")
  markdown = function(md)
    local res = assert(discount.compile(md, 'githubtags', 'fencedcode'))
    return res.body
  end
else
  assert(window and window.marked, "marked.js not found")
  local o
  do
    local mkobj = window:eval("(function () { return {}; })")
    o = function(tbl)
      do
        local obj = mkobj()
        for k, v in pairs(tbl) do
          obj[k] = v
        end
        return obj
      end
    end
  end
  local trim
  trim = function(str)
    return str:match('^ *(..-) *$')
  end
  window.marked:setOptions(o({
    gfm = true,
    smartypants = true,
    langPrefix = 'lang-',
    highlight = function(self, code, lang)
      code = trim(code)
      local result
      if lang and #lang > 0 then
        result = window.hljs:highlight(lang, code, true)
      else
        result = window.hljs:highlightAuto(code)
      end
      return result.value
    end
  }))
  do
    local _base_0 = window
    local _fn_0 = _base_0.marked
    markdown = function(...)
      return _fn_0(_base_0, ...)
    end
  end
end
assert(markdown, "no markdown implementation found")
return {
  {
    inp = 'text/markdown',
    out = 'text/html+frag',
    cost = 1,
    transform = function(self, md)
      return "<div class=\"markdown\">" .. tostring(markdown(md)) .. "</div>"
    end
  },
  {
    inp = 'text/markdown%+sidenotes',
    out = 'text/html+frag',
    cost = 1,
    transform = function(self, md)
      return "<div class=\"markdown sidenote-container\">" .. tostring(markdown(md)) .. "</div>"
    end
  },
  {
    inp = 'text/markdown%+wide',
    out = 'text/html+frag',
    cost = 1,
    transform = function(self, md)
      return "<div class=\"markdown wide\">" .. tostring(markdown(md)) .. "</div>"
    end
  },
  {
    inp = 'text/markdown%+span',
    out = 'text/html+frag',
    cost = 1,
    transform = function(self, source)
      local html = markdown(source)
      html = html:gsub('^%s*<p>%s*', '<span>')
      html = html:gsub('%s*</p>%s*$', '</span>')
      return html
    end
  }
}
