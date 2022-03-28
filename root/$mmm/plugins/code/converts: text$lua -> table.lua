local pre, div, button
do
  local _obj_0 = require('mmm.dom')
  pre, div, button = _obj_0.pre, _obj_0.div, _obj_0.button
end
local languages
languages = require('mmm.highlighting').languages
local Editor
do
  local _class_0
  local o
  local _base_0 = {
    EDITOR = true,
    change = function(self)
      self.timeout = nil
      local doc = self.cm:getDoc()
      if self.lastPreview and doc:isClean(self.lastPreview) then
        return 
      end
      self.lastPreview = doc:changeGeneration()
      local value = doc:getValue()
      self.fileder.facets[self.key] = value
      return BROWSER:refresh()
    end,
    save = function(self, e)
      e:preventDefault()
      local doc = self.cm:getDoc()
      self.fileder:set(self.key, doc:getValue())
      self.lastSave = doc:changeGeneration(true)
    end
  }
  _base_0.__index = _base_0
  _class_0 = setmetatable({
    __init = function(self, value, mode, fileder, key)
      self.fileder, self.key = fileder, key
      self.node = div({
        class = 'editor'
      })
      do
        local _with_0 = button('save')
        _with_0.disabled = true
        _with_0.onclick = function(_, e)
          return self:save(e)
        end
        self.saveBtn = _with_0
      end
      self.cm = window:CodeMirror(self.node, o({
        value = value,
        mode = mode,
        lineNumber = true,
        lineWrapping = true,
        autoRefresh = true,
        theme = 'hybrid'
      }))
      self.lastSave = self.cm:getDoc():changeGeneration(true)
      return self.cm:on('changes', function(_, mirr)
        local doc = self.cm:getDoc()
        self.saveBtn.disabled = doc:isClean(self.lastSave)
        if self.timeout then
          window:clearTimeout(self.timeout)
        end
        self.timeout = window:setTimeout((function()
          return self:change()
        end), 300)
      end)
    end,
    __base = _base_0,
    __name = "Editor"
  }, {
    __index = _base_0,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  local self = _class_0
  if MODE == 'CLIENT' then
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
  Editor = _class_0
end
local _ = [[  editors: if MODE == 'CLIENT' then {
    {
      inp: 'text/([^ ]*).*'
      out: 'mmm/dom'
      cost: 0
      transform: (value, fileder, key) =>
        mode = @from\match @convert.inp
        Editor value, mode, fileder, key
    }
    {
      inp: 'URL.*'
      out: 'mmm/dom'
      cost: 0
      transform: (value, fileder, key) =>
        Editor value, nil, fileder, key
    }
  }
]]
return {
  {
    inp = 'text/([^ ]*).*',
    out = 'mmm/dom',
    cost = 5,
    transform = function(self, val)
      local lang = self.from:match(self.convert.inp)
      return pre(languages[lang](val))
    end
  }
}
