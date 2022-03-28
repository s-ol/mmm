local div, span, sup, a, i, b
do
  local _obj_0 = require('mmm.dom')
  div, span, sup, a, i, b = _obj_0.div, _obj_0.span, _obj_0.sup, _obj_0.a, _obj_0.i, _obj_0.b
end
local parse_bibtex
parse_bibtex = function(src)
  local type, key, kv = src:match('@(%w+){(.-),(.*)}')
  do
    local info = {
      _type = type,
      _key = key
    }
    for key, val in kv:gmatch('([a-z]-)%s*=%s*(%b{})') do
      val:sub(2, -2)
      info[key] = val:gsub('[{}]', '')
    end
    for key, val in kv:gmatch('([a-z]-)%s*=%s*(%d+)') do
      info[key] = val
    end
    return info
  end
end
local title
title = function(self)
  assert(self.title, "cite doesn't have title")
  local inner = i(self.title)
  if self.url then
    return a(inner, {
      href = self.url,
      style = {
        display = 'inline'
      }
    })
  else
    return b(inner)
  end
end
local format_full
format_full = function(self)
  local tt = title(self)
  local dot, com
  if self.title:match('[.?!]$') then
    dot, com = '', ''
  else
    dot, com = '.', ','
  end
  self.author = self.author or 'N. N.'
  local _exp_0 = self._type
  if 'book' == _exp_0 or 'article' == _exp_0 then
    return span((function()
      do
        local _with_0 = setmetatable({ }, {
          __index = table
        })
        _with_0:insert(tostring(self.author) .. " (" .. tostring(self.year) .. "), ")
        _with_0:insert(tt)
        if self.journal then
          _with_0:insert(tostring(dot) .. " ")
          _with_0:insert(i(self.journal))
          if self.volume then
            _with_0:insert(", volume " .. tostring(self.volume))
          end
        else
          if self.series then
            _with_0:insert(tostring(dot) .. " ")
            _with_0:insert(i(self.series))
            if self.number then
              _with_0:insert(", No. " .. tostring(self.number))
            end
          end
        end
        if self.pages then
          _with_0:insert(", pages " .. tostring(self.pages))
        end
        if self.publisher then
          _with_0:insert(tostring(dot) .. " " .. tostring(self.publisher))
        end
        if self.doi then
          _with_0:insert(tostring(dot) .. " ")
          _with_0:insert(a("doi:" .. tostring(self.doi), {
            href = "https://doi.org/" .. tostring(self.doi)
          }))
        end
        return _with_0
      end
    end)())
  elseif 'web' == _exp_0 or 'online' == _exp_0 then
    return span((function()
      do
        local _with_0 = setmetatable({ }, {
          __index = table
        })
        _with_0:insert(tostring(self.author))
        if self.year then
          _with_0:insert(" (" .. tostring(self.year) .. ")")
        end
        _with_0:insert(", ")
        _with_0:insert(tt)
        _with_0:insert(tostring(com) .. " " .. tostring(self.url))
        if self.visited then
          _with_0:insert(" from " .. tostring(self.visited))
        end
        return _with_0
      end
    end)())
  else
    span((function()
      do
        local _with_0 = setmetatable({ }, {
          __index = table
        })
        _with_0:insert(tostring(self.author) .. " (" .. tostring(self.year) .. "), ")
        _with_0:insert(tt)
        if self.publisher then
          _with_0:insert(tostring(dot) .. " " .. tostring(self.publisher))
        end
        return _with_0
      end
    end)())
    return span(tbl)
  end
end
return {
  {
    inp = 'cite/doi',
    out = 'URL -> text/bibtex',
    cost = 0.1,
    transform = function(self, doi)
      doi = doi:match('(10%.%d%d%d%d%d?%d?%d?%d?%d?/[%d%w%.%-_:;%(%)]+)')
      return "http://api.crossref.org/works/" .. tostring(doi) .. "/transform/application/x-bibtex"
    end
  },
  {
    inp = 'text/bibtex',
    out = 'mmm/dom',
    cost = 1,
    transform = function(self, bib)
      return format_full(parse_bibtex(bib))
    end
  }
}
