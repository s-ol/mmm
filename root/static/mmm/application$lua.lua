local p = package.preload
if not p["mmm.canvasapp"] then p["mmm.canvasapp"] = load("local window = js.global\
local js = require('js')\
local a, canvas, div, button, script\
do\
  local _obj_0 = require('mmm.dom')\
  a, canvas, div, button, script = _obj_0.a, _obj_0.canvas, _obj_0.div, _obj_0.button, _obj_0.script\
end\
local CanvasApp\
do\
  local _class_0\
  local _base_0 = {\
    width = 500,\
    height = 400,\
    update = function(self, dt)\
      self.time = self.time + dt\
      if self.length and self.time > self.length then\
        self.time = self.time - self.length\
        return true\
      end\
    end,\
    render = function(self, fps)\
      if fps == nil then\
        fps = 60\
      end\
      assert(self.length, 'cannot render CanvasApp without length set')\
      self.paused = true\
      local actual_render\
      actual_render = function()\
        local writer = js.new(window.Whammy.Video, fps)\
        local doFrame\
        doFrame = function()\
          local done = self:update(1 / fps)\
          self.ctx:resetTransform()\
          self:draw()\
          writer:add(self.canvas)\
          if done or self.time >= self.length then\
            local blob = writer:compile()\
            local name = tostring(self.__class.__name) .. \"_\" .. tostring(fps) .. \"fps.webm\"\
            return self.node.lastChild:appendChild(a(name, {\
              download = name,\
              href = window.URL:createObjectURL(blob)\
            }))\
          else\
            return window:setTimeout(doFrame)\
          end\
        end\
        self.time = 0\
        return doFrame()\
      end\
      if window.Whammy then\
        return actual_render()\
      else\
        window.global = window.global or window\
        return document.body:appendChild(script({\
          onload = actual_render,\
          src = 'https://cdn.jsdelivr.net/npm/whammy@0.0.1/whammy.min.js'\
        }))\
      end\
    end\
  }\
  _base_0.__index = _base_0\
  _class_0 = setmetatable({\
    __init = function(self, show_menu, paused)\
      if show_menu == nil then\
        show_menu = false\
      end\
      self.paused = paused\
      self.canvas = canvas({\
        width = self.width,\
        height = self.height\
      })\
      self.ctx = self.canvas:getContext('2d')\
      self.time = 0\
      self.canvas.tabIndex = 0\
      self.canvas:addEventListener('click', function(_, e)\
        return self.click and self:click(e.offsetX, e.offsetY, e.button)\
      end)\
      self.canvas:addEventListener('keydown', function(_, e)\
        return self.keydown and self:keydown(e.key, e.code)\
      end)\
      local lastMillis = window.performance:now()\
      local animationFrame\
      animationFrame = function(_, millis)\
        self:update((millis - lastMillis) / 1000)\
        self.ctx:resetTransform()\
        self:draw()\
        lastMillis = millis\
        if not self.paused then\
          return window:setTimeout((function()\
            return window:requestAnimationFrame(animationFrame)\
          end), 0)\
        end\
      end\
      window:requestAnimationFrame(animationFrame)\
      if show_menu then\
        self.node = div({\
          className = 'canvas_app',\
          self.canvas,\
          div({\
            className = 'overlay',\
            button('render 30fps', {\
              onclick = function()\
                return self:render(30)\
              end\
            }),\
            button('render 60fps', {\
              onclick = function()\
                return self:render(60)\
              end\
            })\
          })\
        })\
      else\
        self.node = self.canvas\
      end\
    end,\
    __base = _base_0,\
    __name = \"CanvasApp\"\
  }, {\
    __index = _base_0,\
    __call = function(cls, ...)\
      local _self_0 = setmetatable({}, _base_0)\
      cls.__init(_self_0, ...)\
      return _self_0\
    end\
  })\
  _base_0.__class = _class_0\
  CanvasApp = _class_0\
end\
return {\
  CanvasApp = CanvasApp\
}\
", "mmm/canvasapp.client.lua") end
if not p["mmm.color"] then p["mmm.color"] = load("local rgb\
rgb = function(r, g, b)\
  if 'table' == type(r) then\
    r, g, b = table.unpack(r)\
  end\
  return \"rgb(\" .. tostring(r * 255) .. \", \" .. tostring(g * 255) .. \", \" .. tostring(b * 255) .. \")\"\
end\
local rgba\
rgba = function(r, g, b, a)\
  if 'table' == type(r) then\
    r, g, b, a = table.unpack(r)\
  end\
  return \"rgba(\" .. tostring(r * 255) .. \", \" .. tostring(g * 255) .. \", \" .. tostring(b * 255) .. \", \" .. tostring(a or 1) .. \")\"\
end\
local hsl\
hsl = function(h, s, l)\
  if 'table' == type(h) then\
    h, s, l = table.unpack(h)\
  end\
  return \"hsl(\" .. tostring(h * 360) .. \", \" .. tostring(s * 100) .. \"%, \" .. tostring(l * 100) .. \"%)\"\
end\
local hsla\
hsla = function(h, s, l, a)\
  if 'table' == type(h) then\
    h, s, l, a = table.unpack(h)\
  end\
  return \"hsla(\" .. tostring(h * 360) .. \", \" .. tostring(s * 100) .. \"%, \" .. tostring(l * 100) .. \"%, \" .. tostring(a or 1) .. \")\"\
end\
return {\
  rgb = rgb,\
  rgba = rgba,\
  hsl = hsl,\
  hsla = hsla\
}\
", "mmm/color.lua") end
if not p["mmm.highlighting"] then p["mmm.highlighting"] = load("local code\
code = require('mmm.dom').code\
local highlight\
local trim\
trim = function(str)\
  return str:match('^ *(..-) *$')\
end\
if MODE == 'SERVER' then\
  highlight = function(lang, str)\
    assert(str, 'no string to highlight')\
    return code((trim(str)), {\
      class = \"hljs lang-\" .. tostring(lang)\
    })\
  end\
else\
  highlight = function(lang, str)\
    assert(str, 'no string to highlight')\
    local result = window.hljs:highlight(lang, (trim(str)), true)\
    do\
      local _with_0 = code({\
        class = \"hljs lang-\" .. tostring(lang)\
      })\
      _with_0.innerHTML = result.value\
      return _with_0\
    end\
  end\
end\
local languages = setmetatable({ }, {\
  __index = function(self, name)\
    do\
      local val\
      val = function(str)\
        return highlight(name, str)\
      end\
      self[name] = val\
      return val\
    end\
  end\
})\
return {\
  highlight = highlight,\
  languages = languages\
}\
", "mmm/highlighting.lua") end
if not p["mmm"] then p["mmm"] = load("window = js.global\
local console\
document, console = window.document, window.console\
MODE = 'CLIENT'\
local deep_tostring\
deep_tostring = function(tbl, space)\
  if space == nil then\
    space = ''\
  end\
  if 'userdata' == type(tbl) then\
    return tbl\
  end\
  local buf = space .. tostring(tbl)\
  if not ('table' == type(tbl)) then\
    return buf\
  end\
  buf = buf .. ' {\\n'\
  for k, v in pairs(tbl) do\
    buf = buf .. tostring(space) .. \" [\" .. tostring(k) .. \"]: \" .. tostring(deep_tostring(v, space .. '  ')) .. \"\\n\"\
  end\
  buf = buf .. tostring(space) .. \"}\"\
  return buf\
end\
print = function(...)\
  local contents\
  do\
    local _accum_0 = { }\
    local _len_0 = 1\
    local _list_0 = {\
      ...\
    }\
    for _index_0 = 1, #_list_0 do\
      local v = _list_0[_index_0]\
      _accum_0[_len_0] = deep_tostring(v)\
      _len_0 = _len_0 + 1\
    end\
    contents = _accum_0\
  end\
  return console:log(table.unpack(contents))\
end\
warn = function(...)\
  local contents\
  do\
    local _accum_0 = { }\
    local _len_0 = 1\
    local _list_0 = {\
      ...\
    }\
    for _index_0 = 1, #_list_0 do\
      local v = _list_0[_index_0]\
      _accum_0[_len_0] = deep_tostring(v)\
      _len_0 = _len_0 + 1\
    end\
    contents = _accum_0\
  end\
  return console:warn(table.unpack(contents))\
end\
package.path = '/?.lua;/?/init.lua'\
do\
  local _require = require\
  relative = function(base, sub)\
    if not ('number' == type(sub)) then\
      sub = 0\
    end\
    for i = 1, sub do\
      base = base:match('^(.*)%.%w+$')\
    end\
    return function(name, x)\
      if '.' == name:sub(1, 1) then\
        name = base .. name\
      end\
      return _require(name)\
    end\
  end\
end\
if on_load then\
  for _index_0 = 1, #on_load do\
    local f = on_load[_index_0]\
    f()\
  end\
end\
on_load = setmetatable({ }, {\
  __newindex = function(t, k, v)\
    rawset(t, k, v)\
    return v()\
  end\
})\
", "mmm/init.client.lua") end
if not p["mmm.ordered"] then p["mmm.ordered"] = load("local sort\
sort = function(t, order_fn, only_strings)\
  do\
    local index\
    do\
      local _accum_0 = { }\
      local _len_0 = 1\
      for k, v in pairs(t) do\
        if (not only_strings) or 'string' == type(k) then\
          _accum_0[_len_0] = k\
          _len_0 = _len_0 + 1\
        end\
      end\
      index = _accum_0\
    end\
    table.sort(index, order_fn)\
    return index\
  end\
end\
local onext\
onext = function(state, key)\
  state.i = state.i + state.step\
  local t, index, i\
  t, index, i = state.t, state.index, state.i\
  do\
    key = index[i]\
    if key then\
      return key, t[key]\
    end\
  end\
end\
local opairs\
opairs = function(t, order_fn, only_strings)\
  if only_strings == nil then\
    only_strings = false\
  end\
  local state = {\
    t = t,\
    i = 0,\
    step = 1,\
    index = sort(t, order_fn, only_strings)\
  }\
  return onext, state, nil\
end\
local ropairs\
ropairs = function(t, order_fn, only_strings)\
  if only_strings == nil then\
    only_strings = false\
  end\
  local index = sort(t, order_fn, only_strings)\
  local state = {\
    t = t,\
    index = index,\
    i = #index + 1,\
    step = -1\
  }\
  return onext, state, nil\
end\
return {\
  onext = onext,\
  opairs = opairs,\
  ropairs = ropairs\
}\
", "mmm/ordered.lua") end
if not p["mmm.mmmfs.browser"] then p["mmm.mmmfs.browser"] = load("local require = relative(..., 1)\
local Key\
Key = require('.fileder').Key\
local converts, get_conversions, apply_conversions\
do\
  local _obj_0 = require('.conversion')\
  converts, get_conversions, apply_conversions = _obj_0.converts, _obj_0.get_conversions, _obj_0.apply_conversions\
end\
local ReactiveVar, get_or_create, text, elements\
do\
  local _obj_0 = require('mmm.component')\
  ReactiveVar, get_or_create, text, elements = _obj_0.ReactiveVar, _obj_0.get_or_create, _obj_0.text, _obj_0.elements\
end\
local pre, div, nav, span, button, a, code, select, option\
pre, div, nav, span, button, a, code, select, option = elements.pre, elements.div, elements.nav, elements.span, elements.button, elements.a, elements.code, elements.select, elements.option\
local languages\
languages = require('mmm.highlighting').languages\
local keep\
keep = function(var)\
  local last = var:get()\
  return var:map(function(val)\
    last = val or last\
    return last\
  end)\
end\
local code_cast\
code_cast = function(lang)\
  return {\
    inp = \"text/\" .. tostring(lang) .. \".*\",\
    out = 'mmm/dom',\
    transform = function(val)\
      return languages[lang](val)\
    end\
  }\
end\
local casts = {\
  code_cast('javascript'),\
  code_cast('moonscript'),\
  code_cast('lua'),\
  code_cast('markdown'),\
  code_cast('html'),\
  {\
    inp = 'text/plain',\
    out = 'mmm/dom',\
    transform = function(val)\
      return text(val)\
    end\
  },\
  {\
    inp = 'URL.*',\
    out = 'mmm/dom',\
    transform = function(href)\
      return span(a((code(href)), {\
        href = href\
      }))\
    end\
  }\
}\
for _index_0 = 1, #converts do\
  local convert = converts[_index_0]\
  table.insert(casts, convert)\
end\
local Browser\
do\
  local _class_0\
  local err_and_trace, default_convert\
  local _base_0 = {\
    get_content = function(self, prop, err, convert)\
      if err == nil then\
        err = self.error\
      end\
      if convert == nil then\
        convert = default_convert\
      end\
      local clear_error\
      clear_error = function()\
        if MODE == 'CLIENT' then\
          return err:set()\
        end\
      end\
      local disp_error\
      disp_error = function(msg)\
        if MODE == 'CLIENT' then\
          err:set(pre(msg))\
        end\
        warn(\"ERROR rendering content: \" .. tostring(msg))\
        return nil\
      end\
      local active = self.active:get()\
      if not (active) then\
        return disp_error(\"fileder not found!\")\
      end\
      if not (prop) then\
        return disp_error(\"facet not found!\")\
      end\
      local ok, res = xpcall(convert, err_and_trace, active, prop)\
      if MODE == 'CLIENT' then\
        document.body.classList:remove('loading')\
      end\
      if ok and res then\
        clear_error()\
        return res\
      elseif ok then\
        return div(\"[no conversion path to \" .. tostring(prop.type) .. \"]\")\
      elseif res and res.msg.match and res.msg:match('%[nossr%]$') then\
        return div(\"[this page could not be pre-rendered on the server]\")\
      else\
        res = tostring(res.msg) .. \"\\n\" .. tostring(res.trace)\
        return disp_error(res)\
      end\
    end,\
    get_inspector = function(self)\
      self.inspect_prop = self.facet:map(function(prop)\
        local active = self.active:get()\
        local key = active and active:find(prop)\
        if key and key.original then\
          key = key.original\
        end\
        return key\
      end)\
      self.inspect_err = ReactiveVar()\
      do\
        local _with_0 = div({\
          class = 'view inspector'\
        })\
        _with_0:append(nav({\
          span('inspector'),\
          self.inspect_prop:map(function(current)\
            current = current and current:tostring()\
            local fileder = self.active:get()\
            local onchange\
            onchange = function(_, e)\
              if e.target.value == '' then\
                return \
              end\
              local name\
              name = self.facet:get().name\
              return self.inspect_prop:set(Key(e.target.value))\
            end\
            do\
              local _with_1 = select({\
                onchange = onchange\
              })\
              _with_1:append(option('(none)', {\
                value = '',\
                disabled = true,\
                selected = not value\
              }))\
              if fileder then\
                for key, _ in pairs(fileder.facets) do\
                  local value = key:tostring()\
                  _with_1:append(option(value, {\
                    value = value,\
                    selected = value == current\
                  }))\
                end\
              end\
              return _with_1\
            end\
          end),\
          self.inspect:map(function(enabled)\
            if enabled then\
              return button('close', {\
                onclick = function(_, e)\
                  return self.inspect:set(false)\
                end\
              })\
            end\
          end)\
        }))\
        _with_0:append((function()\
          do\
            local _with_1 = div({\
              class = self.inspect_err:map(function(e)\
                if e then\
                  return 'error-wrap'\
                else\
                  return 'error-wrap empty'\
                end\
              end)\
            })\
            _with_1:append(span(\"an error occured while rendering this view:\"))\
            _with_1:append(self.inspect_err)\
            return _with_1\
          end\
        end)())\
        _with_0:append((function()\
          do\
            local _with_1 = pre({\
              class = 'content'\
            })\
            _with_1:append(keep(self.inspect_prop:map(function(prop, old)\
              return self:get_content(prop, self.inspect_err, function(self, prop)\
                local value, key = self:get(prop)\
                assert(key, \"couldn't @get \" .. tostring(prop))\
                local conversions = get_conversions('mmm/dom', key.type, casts)\
                assert(conversions, \"cannot cast '\" .. tostring(key.type) .. \"'\")\
                return apply_conversions(conversions, value, self, prop)\
              end)\
            end)))\
            return _with_1\
          end\
        end)())\
        return _with_0\
      end\
    end,\
    navigate = function(self, new)\
      return self.path:set(new)\
    end\
  }\
  _base_0.__index = _base_0\
  _class_0 = setmetatable({\
    __init = function(self, root, path, rehydrate)\
      if rehydrate == nil then\
        rehydrate = false\
      end\
      self.root = root\
      assert(self.root, 'root fileder is nil')\
      self.path = ReactiveVar(path or '')\
      if MODE == 'CLIENT' then\
        local logo = document:querySelector('header h1 > svg')\
        local spin\
        spin = function()\
          logo.classList:add('spin')\
          local _ = logo.parentElement.offsetWidth\
          return logo.classList:remove('spin')\
        end\
        self.path:subscribe(function(path)\
          document.body.classList:add('loading')\
          spin()\
          if self.skip then\
            return \
          end\
          local vis_path = path .. ((function()\
            if '/' == path:sub(-1) then\
              return ''\
            else\
              return '/'\
            end\
          end)())\
          return window.history:pushState(path, '', vis_path)\
        end)\
        window.onpopstate = function(_, event)\
          if event.state and not event.state == js.null then\
            self.skip = true\
            self.path:set(event.state)\
            self.skip = nil\
          end\
        end\
      end\
      self.active = self.path:map((function()\
        local _base_1 = self.root\
        local _fn_0 = _base_1.walk\
        return function(...)\
          return _fn_0(_base_1, ...)\
        end\
      end)())\
      self.facet = self.active:map(function(fileder)\
        if not (fileder) then\
          return \
        end\
        local last = self.facet and self.facet:get()\
        return Key((function()\
          if last then\
            return last.type\
          else\
            return 'mmm/dom'\
          end\
        end)())\
      end)\
      self.inspect = ReactiveVar((MODE == 'CLIENT' and window.location.search:match('[?&]inspect')))\
      local main = get_or_create('div', 'browser-root', {\
        class = 'main view'\
      })\
      if MODE == 'SERVER' then\
        main:append(nav({\
          id = 'browser-navbar',\
          span('please stand by... interactivity loading :)')\
        }))\
      else\
        main:prepend((function()\
          do\
            local _with_0 = get_or_create('nav', 'browser-navbar')\
            _with_0.node.innerHTML = ''\
            _with_0:append(span('path: ', self.path:map(function(path)\
              do\
                local _with_1 = div({\
                  class = 'path',\
                  style = {\
                    display = 'inline-block'\
                  }\
                })\
                local path_segment\
                path_segment = function(name, href)\
                  return a(name, {\
                    href = href,\
                    onclick = function(_, e)\
                      e:preventDefault()\
                      return self:navigate(href)\
                    end\
                  })\
                end\
                local href = ''\
                path = path:match('^/(.*)')\
                _with_1:append(path_segment('root', ''))\
                while path do\
                  local name, rest = path:match('^([%w%-_%.]+)/(.*)')\
                  if not name then\
                    name = path\
                  end\
                  path = rest\
                  href = tostring(href) .. \"/\" .. tostring(name)\
                  _with_1:append('/')\
                  _with_1:append(path_segment(name, href))\
                end\
                return _with_1\
              end\
            end)))\
            _with_0:append(span('view facet:', {\
              style = {\
                ['margin-right'] = '0'\
              }\
            }))\
            _with_0:append(self.active:map(function(fileder)\
              local onchange\
              onchange = function(_, e)\
                local type\
                type = self.facet:get().type\
                return self.facet:set(Key({\
                  name = e.target.value,\
                  type = type\
                }))\
              end\
              local current = self.facet:get()\
              current = current and current.name\
              do\
                local _with_1 = select({\
                  onchange = onchange,\
                  disabled = not fileder\
                })\
                local has_main = fileder and fileder:find(current.name, '.*')\
                _with_1:append(option('(main)', {\
                  value = '',\
                  disabled = not has_main,\
                  selected = current == ''\
                }))\
                if fileder then\
                  for i, value in ipairs(fileder:get_facets()) do\
                    local _continue_0 = false\
                    repeat\
                      if value == '' then\
                        _continue_0 = true\
                        break\
                      end\
                      _with_1:append(option(value, {\
                        value = value,\
                        selected = value == current\
                      }))\
                      _continue_0 = true\
                    until true\
                    if not _continue_0 then\
                      break\
                    end\
                  end\
                end\
                return _with_1\
              end\
            end))\
            _with_0:append(self.inspect:map(function(enabled)\
              if not enabled then\
                return button('inspect', {\
                  onclick = function(_, e)\
                    return self.inspect:set(true)\
                  end\
                })\
              end\
            end))\
            return _with_0\
          end\
        end)())\
      end\
      self.error = ReactiveVar()\
      main:append((function()\
        do\
          local _with_0 = get_or_create('div', 'browser-error', {\
            class = self.error:map(function(e)\
              if e then\
                return 'error-wrap'\
              else\
                return 'error-wrap empty'\
              end\
            end)\
          })\
          _with_0:append((span(\"an error occured while rendering this view:\")), (rehydrate and _with_0.node.firstChild))\
          _with_0:append(self.error)\
          return _with_0\
        end\
      end)())\
      main:append((function()\
        do\
          local _with_0 = get_or_create('div', 'browser-content', {\
            class = 'content'\
          })\
          local content = ReactiveVar((function()\
            if rehydrate then\
              return _with_0.node.lastChild\
            else\
              return self:get_content(self.facet:get())\
            end\
          end)())\
          _with_0:append(keep(content))\
          if MODE == 'CLIENT' then\
            self.facet:subscribe(function(p)\
              return window:setTimeout((function()\
                return content:set(self:get_content(p))\
              end), 150)\
            end)\
          end\
          return _with_0\
        end\
      end)())\
      if rehydrate then\
        self.facet:set(self.facet:get())\
      end\
      local inspector = self.inspect:map(function(enabled)\
        if enabled then\
          return self:get_inspector()\
        end\
      end)\
      local wrapper = get_or_create('div', 'browser-wrapper', main, inspector, {\
        class = 'browser'\
      })\
      self.node = wrapper.node\
      do\
        local _base_1 = wrapper\
        local _fn_0 = _base_1.render\
        self.render = function(...)\
          return _fn_0(_base_1, ...)\
        end\
      end\
    end,\
    __base = _base_0,\
    __name = \"Browser\"\
  }, {\
    __index = _base_0,\
    __call = function(cls, ...)\
      local _self_0 = setmetatable({}, _base_0)\
      cls.__init(_self_0, ...)\
      return _self_0\
    end\
  })\
  _base_0.__class = _class_0\
  local self = _class_0\
  err_and_trace = function(msg)\
    return {\
      msg = msg,\
      trace = debug.traceback()\
    }\
  end\
  default_convert = function(self, key)\
    return self:get(key.name, 'mmm/dom')\
  end\
  default_convert = function(self, key)\
    return self:get(key.name, 'mmm/dom')\
  end\
  Browser = _class_0\
end\
return {\
  Browser = Browser\
}\
", "mmm/mmmfs/browser.lua") end
if not p["mmm.mmmfs.conversion"] then p["mmm.mmmfs.conversion"] = load("local require = relative(..., 1)\
local converts = require('.converts')\
local count\
count = function(base, pattern)\
  if pattern == nil then\
    pattern = '->'\
  end\
  return select(2, base:gsub(pattern, ''))\
end\
local escape_pattern\
escape_pattern = function(inp)\
  return \"^\" .. tostring(inp:gsub('([^%w])', '%%%1')) .. \"$\"\
end\
local escape_inp\
escape_inp = function(inp)\
  return \"^\" .. tostring(inp:gsub('([-/])', '%%%1')) .. \"$\"\
end\
local get_conversions\
get_conversions = function(want, have, _converts, limit)\
  if _converts == nil then\
    _converts = converts\
  end\
  if limit == nil then\
    limit = 5\
  end\
  assert(have, 'need starting type(s)')\
  if 'string' == type(have) then\
    have = {\
      have\
    }\
  end\
  assert(#have > 0, 'need starting type(s) (list was empty)')\
  want = escape_pattern(want)\
  local iterations = limit + math.max(table.unpack((function()\
    local _accum_0 = { }\
    local _len_0 = 1\
    for _index_0 = 1, #have do\
      local type = have[_index_0]\
      _accum_0[_len_0] = count(type)\
      _len_0 = _len_0 + 1\
    end\
    return _accum_0\
  end)()))\
  do\
    local _accum_0 = { }\
    local _len_0 = 1\
    for _index_0 = 1, #have do\
      local start = have[_index_0]\
      _accum_0[_len_0] = {\
        start = start,\
        rest = start,\
        conversions = { }\
      }\
      _len_0 = _len_0 + 1\
    end\
    have = _accum_0\
  end\
  for i = 1, iterations do\
    local next_have, c = { }, 1\
    for _index_0 = 1, #have do\
      local _des_0 = have[_index_0]\
      local start, rest, conversions\
      start, rest, conversions = _des_0.start, _des_0.rest, _des_0.conversions\
      if rest:match(want) then\
        return conversions, start\
      else\
        for _index_1 = 1, #_converts do\
          local _continue_0 = false\
          repeat\
            local convert = _converts[_index_1]\
            local inp = escape_inp(convert.inp)\
            if not (rest:match(inp)) then\
              _continue_0 = true\
              break\
            end\
            local result = rest:gsub(inp, convert.out)\
            if result then\
              next_have[c] = {\
                start = start,\
                rest = result,\
                conversions = {\
                  {\
                    convert = convert,\
                    from = rest,\
                    to = result\
                  },\
                  table.unpack(conversions)\
                }\
              }\
              c = c + 1\
            end\
            _continue_0 = true\
          until true\
          if not _continue_0 then\
            break\
          end\
        end\
      end\
    end\
    have = next_have\
    if not (#have > 0) then\
      return \
    end\
  end\
end\
local apply_conversions\
apply_conversions = function(conversions, value, ...)\
  for i = #conversions, 1, -1 do\
    local step = conversions[i]\
    value = step.convert.transform(step, value, ...)\
  end\
  return value\
end\
return {\
  converts = converts,\
  get_conversions = get_conversions,\
  apply_conversions = apply_conversions\
}\
", "mmm/mmmfs/conversion.lua") end
if not p["mmm.mmmfs.fileder"] then p["mmm.mmmfs.fileder"] = load("local require = relative(..., 1)\
local get_conversions, apply_conversions\
do\
  local _obj_0 = require('.conversion')\
  get_conversions, apply_conversions = _obj_0.get_conversions, _obj_0.apply_conversions\
end\
local Key\
do\
  local _class_0\
  local _base_0 = {\
    tostring = function(self)\
      if self.name == '' then\
        return self.type\
      else\
        return tostring(self.name) .. \": \" .. tostring(self.type)\
      end\
    end,\
    __tostring = function(self)\
      return self:tostring()\
    end\
  }\
  _base_0.__index = _base_0\
  _class_0 = setmetatable({\
    __init = function(self, opts, second)\
      if 'string' == type(second) then\
        self.name, self.type = (opts or ''), second\
      elseif 'string' == type(opts) then\
        self.name, self.type = opts:match('^([%w-_]+): *(.+)$')\
        if not self.name then\
          self.name = ''\
          self.type = opts\
        end\
      elseif 'table' == type(opts) then\
        self.name = opts.name\
        self.type = opts.type\
        self.original = opts.original\
        self.filename = opts.filename\
      else\
        return error(\"wrong argument type: \" .. tostring(type(opts)) .. \", \" .. tostring(type(second)))\
      end\
    end,\
    __base = _base_0,\
    __name = \"Key\"\
  }, {\
    __index = _base_0,\
    __call = function(cls, ...)\
      local _self_0 = setmetatable({}, _base_0)\
      cls.__init(_self_0, ...)\
      return _self_0\
    end\
  })\
  _base_0.__class = _class_0\
  Key = _class_0\
end\
local Fileder\
do\
  local _class_0\
  local _base_0 = {\
    walk = function(self, path)\
      if path == '' then\
        return self\
      end\
      if '/' ~= path:sub(1, 1) then\
        path = tostring(self.path) .. \"/\" .. tostring(path)\
      end\
      if not (self.path == path:sub(1, #self.path)) then\
        return \
      end\
      if #path == #self.path then\
        return self\
      end\
      local _list_0 = self.children\
      for _index_0 = 1, #_list_0 do\
        local child = _list_0[_index_0]\
        do\
          local match = child:walk(path)\
          if match then\
            return match\
          end\
        end\
      end\
    end,\
    mount = function(self, path, mount_as)\
      if not mount_as then\
        path = path .. self:gett('name: alpha')\
      end\
      assert(not self.path or self.path == path, \"mounted twice: \" .. tostring(self.path) .. \" and now \" .. tostring(path))\
      self.path = path\
      local _list_0 = self.children\
      for _index_0 = 1, #_list_0 do\
        local child = _list_0[_index_0]\
        child:mount(self.path .. '/')\
      end\
    end,\
    iterate = function(self, depth)\
      if depth == nil then\
        depth = 0\
      end\
      coroutine.yield(self)\
      if depth == 1 then\
        return \
      end\
      local _list_0 = self.children\
      for _index_0 = 1, #_list_0 do\
        local child = _list_0[_index_0]\
        child:iterate(depth - 1)\
      end\
    end,\
    get_facets = function(self)\
      local names = { }\
      for key in pairs(self.facets) do\
        names[key.name] = true\
      end\
      local _accum_0 = { }\
      local _len_0 = 1\
      for name in pairs(names) do\
        _accum_0[_len_0] = name\
        _len_0 = _len_0 + 1\
      end\
      return _accum_0\
    end,\
    has = function(self, ...)\
      local want = Key(...)\
      for key in pairs(self.facets) do\
        local _continue_0 = false\
        repeat\
          if key.original then\
            _continue_0 = true\
            break\
          end\
          if key.name == want.name and key.type == want.type then\
            return key\
          end\
          _continue_0 = true\
        until true\
        if not _continue_0 then\
          break\
        end\
      end\
    end,\
    has_facet = function(self, want)\
      for key in pairs(self.facets) do\
        local _continue_0 = false\
        repeat\
          if key.original then\
            _continue_0 = true\
            break\
          end\
          if key.name == want then\
            return key\
          end\
          _continue_0 = true\
        until true\
        if not _continue_0 then\
          break\
        end\
      end\
    end,\
    find = function(self, ...)\
      local want = Key(...)\
      local matching\
      do\
        local _accum_0 = { }\
        local _len_0 = 1\
        for key in pairs(self.facets) do\
          if key.name == want.name then\
            _accum_0[_len_0] = key\
            _len_0 = _len_0 + 1\
          end\
        end\
        matching = _accum_0\
      end\
      if not (#matching > 0) then\
        return \
      end\
      local shortest_path, start = get_conversions(want.type, (function()\
        local _accum_0 = { }\
        local _len_0 = 1\
        for _index_0 = 1, #matching do\
          local key = matching[_index_0]\
          _accum_0[_len_0] = key.type\
          _len_0 = _len_0 + 1\
        end\
        return _accum_0\
      end)())\
      if start then\
        for _index_0 = 1, #matching do\
          local key = matching[_index_0]\
          if key.type == start then\
            return key, shortest_path\
          end\
        end\
        return error(\"couldn't find key after resolution?\")\
      end\
    end,\
    get = function(self, ...)\
      local want = Key(...)\
      local key, conversions = self:find(want)\
      if key then\
        local value = apply_conversions(conversions, self.facets[key], self, key)\
        return value, key\
      end\
    end,\
    gett = function(self, ...)\
      local want = Key(...)\
      local value, key = self:get(want)\
      assert(value, tostring(self) .. \" doesn't have value for '\" .. tostring(want) .. \"'\")\
      return value, key\
    end,\
    __tostring = function(self)\
      return \"Fileder:\" .. tostring(self.path)\
    end\
  }\
  _base_0.__index = _base_0\
  _class_0 = setmetatable({\
    __init = function(self, facets, children)\
      if not children then\
        do\
          local _accum_0 = { }\
          local _len_0 = 1\
          for i, child in ipairs(facets) do\
            facets[i] = nil\
            local _value_0 = child\
            _accum_0[_len_0] = _value_0\
            _len_0 = _len_0 + 1\
          end\
          children = _accum_0\
        end\
      end\
      self.children = setmetatable({ }, {\
        __index = function(t, k)\
          if not ('string' == type(k)) then\
            return rawget(t, k)\
          end\
          return self:walk(tostring(self.path) .. \"/\" .. tostring(k))\
        end,\
        __newindex = function(t, k, child)\
          rawset(t, k, child)\
          if self.path == '/' then\
            return child:mount('/')\
          elseif self.path then\
            return child:mount(self.path .. '/')\
          end\
        end\
      })\
      for i, child in ipairs(children) do\
        self.children[i] = child\
      end\
      self.facets = setmetatable({ }, {\
        __newindex = function(t, key, v)\
          return rawset(t, (Key(key)), v)\
        end\
      })\
      for k, v in pairs(facets) do\
        self.facets[k] = v\
      end\
    end,\
    __base = _base_0,\
    __name = \"Fileder\"\
  }, {\
    __index = _base_0,\
    __call = function(cls, ...)\
      local _self_0 = setmetatable({}, _base_0)\
      cls.__init(_self_0, ...)\
      return _self_0\
    end\
  })\
  _base_0.__class = _class_0\
  Fileder = _class_0\
end\
local dir_base\
dir_base = function(path)\
  local dir, base = path:match('(.-)([^/]-)$')\
  if dir and #dir > 0 then\
    dir = dir:sub(1, #dir - 1)\
  end\
  return dir, base\
end\
local load_tree\
load_tree = function(store, root)\
  if root == nil then\
    root = ''\
  end\
  local fileders = setmetatable({ }, {\
    __index = function(self, path)\
      do\
        local val = Fileder({ })\
        val.path = path\
        rawset(self, path, val)\
        return val\
      end\
    end\
  })\
  root = fileders[root]\
  root.facets['name: alpha'] = ''\
  for fn, ft in store:list_facets(root.path) do\
    local val = store:load_facet(root.path, fn, ft)\
    root.facets[Key(fn, ft)] = val\
  end\
  for path in store:list_all_fileders(root.path) do\
    local fileder = fileders[path]\
    local parent, name = dir_base(path)\
    fileder.facets['name: alpha'] = name\
    table.insert(fileders[parent].children, fileder)\
    for fn, ft in store:list_facets(path) do\
      local val = store:load_facet(path, fn, ft)\
      fileder.facets[Key(fn, ft)] = val\
    end\
  end\
  return root\
end\
return {\
  Key = Key,\
  Fileder = Fileder,\
  dir_base = dir_base,\
  load_tree = load_tree\
}\
", "mmm/mmmfs/fileder.lua") end
if not p["mmm.mmmfs"] then p["mmm.mmmfs"] = load("local require = relative(...)\
local Key, Fileder\
do\
  local _obj_0 = require('.fileder')\
  Key, Fileder = _obj_0.Key, _obj_0.Fileder\
end\
local Browser\
Browser = require('.browser').Browser\
return {\
  Key = Key,\
  Fileder = Fileder,\
  Browser = Browser\
}\
", "mmm/mmmfs/init.lua") end
if not p["mmm.mmmfs.util"] then p["mmm.mmmfs.util"] = load("local merge\
merge = function(orig, extra)\
  if orig == nil then\
    orig = { }\
  end\
  do\
    local attr\
    do\
      local _tbl_0 = { }\
      for k, v in pairs(orig) do\
        _tbl_0[k] = v\
      end\
      attr = _tbl_0\
    end\
    for k, v in pairs(extra) do\
      attr[k] = v\
    end\
    return attr\
  end\
end\
local tourl\
tourl = function(path)\
  if STATIC then\
    return path .. '/'\
  else\
    return path .. '/'\
  end\
end\
return function(elements)\
  local a, div, pre\
  a, div, pre = elements.a, elements.div, elements.pre\
  local find_fileder\
  find_fileder = function(fileder, origin)\
    if 'string' == type(fileder) then\
      assert(origin, \"cannot resolve path '\" .. tostring(fileder) .. \"' without origin!\")\
      return assert((origin:walk(fileder)), \"couldn't resolve path '\" .. tostring(fileder) .. \"' from \" .. tostring(origin))\
    else\
      return assert(fileder, \"no fileder passed.\")\
    end\
  end\
  local navigate_to\
  navigate_to = function(path, name, opts)\
    if opts == nil then\
      opts = { }\
    end\
    opts.href = tourl(path)\
    if MODE == 'CLIENT' then\
      opts.onclick = function(self, e)\
        e:preventDefault()\
        return BROWSER:navigate(path)\
      end\
    end\
    return a(name, opts)\
  end\
  local link_to\
  link_to = function(fileder, name, origin, attr)\
    fileder = find_fileder(fileder, origin)\
    name = name or fileder:get('title: mmm/dom')\
    name = name or fileder:gett('name: alpha')\
    do\
      local href = fileder:get('link: URL.*')\
      if href then\
        return a(name, merge(attr, {\
          href = href,\
          target = '_blank'\
        }))\
      else\
        return a(name, merge(attr, {\
          href = tourl(fileder.path),\
          onclick = (function()\
            if MODE == 'CLIENT' then\
              return function(self, e)\
                e:preventDefault()\
                return BROWSER:navigate(fileder.path)\
              end\
            end\
          end)()\
        }))\
      end\
    end\
  end\
  local embed\
  embed = function(fileder, name, origin, opts)\
    if name == nil then\
      name = ''\
    end\
    if opts == nil then\
      opts = { }\
    end\
    fileder = find_fileder(fileder, origin)\
    local ok, node = pcall(fileder.gett, fileder, name, 'mmm/dom')\
    if not ok then\
      return div(\"couldn't embed \" .. tostring(fileder) .. \" \" .. tostring(name), (pre(node)), {\
        style = {\
          background = 'var(--gray-fail)',\
          padding = '1em'\
        }\
      })\
    end\
    local klass = 'embed'\
    if opts.desc then\
      klass = klass .. ' desc'\
    end\
    if opts.inline then\
      klass = klass .. ' inline'\
    end\
    node = div({\
      class = klass,\
      node,\
      (function()\
        if opts.desc then\
          return div(opts.desc, {\
            class = 'description'\
          })\
        end\
      end)()\
    })\
    if opts.nolink then\
      return node\
    end\
    return link_to(fileder, node, nil, opts.attr)\
  end\
  return {\
    find_fileder = find_fileder,\
    link_to = link_to,\
    navigate_to = navigate_to,\
    embed = embed\
  }\
end\
", "mmm/mmmfs/util.lua") end
if not p["mmm.mmmfs.converts"] then p["mmm.mmmfs.converts"] = load("local require = relative(..., 1)\
local div, code, img, video, blockquote, a, span, source, iframe\
do\
  local _obj_0 = require('mmm.dom')\
  div, code, img, video, blockquote, a, span, source, iframe = _obj_0.div, _obj_0.code, _obj_0.img, _obj_0.video, _obj_0.blockquote, _obj_0.a, _obj_0.span, _obj_0.source, _obj_0.iframe\
end\
local find_fileder, link_to, embed\
do\
  local _obj_0 = (require('mmm.mmmfs.util'))(require('mmm.dom'))\
  find_fileder, link_to, embed = _obj_0.find_fileder, _obj_0.link_to, _obj_0.embed\
end\
local render\
render = require('.layout').render\
local tohtml\
tohtml = require('mmm.component').tohtml\
local js_fix\
if MODE == 'CLIENT' then\
  js_fix = function(arg)\
    if arg == js.null then\
      return \
    end\
    return arg\
  end\
end\
local single\
single = function(func)\
  return function(self, val)\
    return func(val)\
  end\
end\
local loadwith\
loadwith = function(_load)\
  return function(self, val, fileder, key)\
    local func = assert(_load(val, tostring(fileder) .. \"#\" .. tostring(key)))\
    return func()\
  end\
end\
local converts = {\
  {\
    inp = 'fn -> (.+)',\
    out = '%1',\
    transform = function(self, val, fileder)\
      return val(fileder)\
    end\
  },\
  {\
    inp = 'mmm/component',\
    out = 'mmm/dom',\
    transform = single(tohtml)\
  },\
  {\
    inp = 'mmm/dom',\
    out = 'text/html+frag',\
    transform = function(self, node)\
      if MODE == 'SERVER' then\
        return node\
      else\
        return node.outerHTML\
      end\
    end\
  },\
  {\
    inp = 'mmm/dom',\
    out = 'text/html',\
    transform = function(self, html, fileder)\
      return render(html, fileder)\
    end\
  },\
  {\
    inp = 'text/html%+frag',\
    out = 'mmm/dom',\
    transform = (function()\
      if MODE == 'SERVER' then\
        return function(self, html, fileder)\
          html = html:gsub('<mmm%-link%s+(.-)>(.-)</mmm%-link>', function(attrs, text)\
            if #text == 0 then\
              text = nil\
            end\
            local path = ''\
            while attrs and attrs ~= '' do\
              local key, val, _attrs = attrs:match('^(%w+)=\"([^\"]-)\"%s*(.*)')\
              if not key then\
                key, _attrs = attrs:match('^(%w+)%s*(.*)$')\
                val = true\
              end\
              attrs = _attrs\
              local _exp_0 = key\
              if 'path' == _exp_0 then\
                path = val\
              else\
                warn(\"unkown attribute '\" .. tostring(key) .. \"=\\\"\" .. tostring(val) .. \"\\\"' in <mmm-link>\")\
              end\
            end\
            return link_to(path, text, fileder)\
          end)\
          html = html:gsub('<mmm%-embed%s+(.-)>(.-)</mmm%-embed>', function(attrs, desc)\
            local path, facet = '', ''\
            local opts = { }\
            if #desc ~= 0 then\
              opts.desc = desc\
            end\
            while attrs and attrs ~= '' do\
              local key, val, _attrs = attrs:match('^(%w+)=\"([^\"]-)\"%s*(.*)')\
              if not key then\
                key, _attrs = attrs:match('^(%w+)%s*(.*)$')\
                val = true\
              end\
              attrs = _attrs\
              local _exp_0 = key\
              if 'path' == _exp_0 then\
                path = val\
              elseif 'facet' == _exp_0 then\
                facet = val\
              elseif 'nolink' == _exp_0 then\
                opts.nolink = true\
              elseif 'inline' == _exp_0 then\
                opts.inline = true\
              else\
                warn(\"unkown attribute '\" .. tostring(key) .. \"=\\\"\" .. tostring(val) .. \"\\\"' in <mmm-embed>\")\
              end\
            end\
            return embed(path, facet, fileder, opts)\
          end)\
          return html\
        end\
      else\
        return function(self, html, fileder)\
          local parent\
          do\
            local _with_0 = document:createElement('div')\
            _with_0.innerHTML = html\
            local embeds = _with_0:getElementsByTagName('mmm-embed')\
            do\
              local _accum_0 = { }\
              local _len_0 = 1\
              for i = 0, embeds.length - 1 do\
                _accum_0[_len_0] = embeds[i]\
                _len_0 = _len_0 + 1\
              end\
              embeds = _accum_0\
            end\
            for _index_0 = 1, #embeds do\
              local element = embeds[_index_0]\
              local path = js_fix(element:getAttribute('path'))\
              local facet = js_fix(element:getAttribute('facet'))\
              local nolink = js_fix(element:getAttribute('nolink'))\
              local inline = js_fix(element:getAttribute('inline'))\
              local desc = js_fix(element.innerText)\
              element:replaceWith(embed(path or '', facet or '', fileder, {\
                nolink = nolink,\
                inline = inline,\
                desc = desc\
              }))\
            end\
            embeds = _with_0:getElementsByTagName('mmm-link')\
            do\
              local _accum_0 = { }\
              local _len_0 = 1\
              for i = 0, embeds.length - 1 do\
                _accum_0[_len_0] = embeds[i]\
                _len_0 = _len_0 + 1\
              end\
              embeds = _accum_0\
            end\
            for _index_0 = 1, #embeds do\
              local element = embeds[_index_0]\
              local text = js_fix(element.innerText)\
              local path = js_fix(element:getAttribute('path'))\
              element:replaceWith(link_to(path or '', text, fileder))\
            end\
            parent = _with_0\
          end\
          assert(1 == parent.childElementCount, \"text/html with more than one child!\")\
          return parent.firstElementChild\
        end\
      end\
    end)()\
  },\
  {\
    inp = 'text/lua -> (.+)',\
    out = '%1',\
    transform = loadwith(load or loadstring)\
  },\
  {\
    inp = 'mmm/tpl -> (.+)',\
    out = '%1',\
    transform = function(self, source, fileder)\
      return source:gsub('{{(.-)}}', function(expr)\
        local path, facet = expr:match('^([%w%-_%./]*)%+(.*)')\
        assert(path, \"couldn't match TPL expression '\" .. tostring(expr) .. \"'\")\
        return (find_fileder(path, fileder)):gett(facet)\
      end)\
    end\
  },\
  {\
    inp = 'time/iso8601-date',\
    out = 'time/unix',\
    transform = function(self, val)\
      local year, _, month, day = val:match('^%s*(%d%d%d%d)(%-?)([01]%d)%2([0-3]%d)%s*$')\
      assert(year, \"failed to parse ISO 8601 date: '\" .. tostring(val) .. \"'\")\
      return os.time({\
        year = year,\
        month = month,\
        day = day\
      })\
    end\
  },\
  {\
    inp = 'URL -> twitter/tweet',\
    out = 'mmm/dom',\
    transform = function(self, href)\
      local id = assert((href:match('twitter.com/[^/]-/status/(%d*)')), \"couldn't parse twitter/tweet URL: '\" .. tostring(href) .. \"'\")\
      if MODE == 'CLIENT' then\
        do\
          local parent = div()\
          window.twttr.widgets:createTweet(id, parent)\
          return parent\
        end\
      else\
        return div(blockquote({\
          class = 'twitter-tweet',\
          ['data-lang'] = 'en',\
          a('(linked tweet)', {\
            href = href\
          })\
        }))\
      end\
    end\
  },\
  {\
    inp = 'URL -> youtube/video',\
    out = 'mmm/dom',\
    transform = function(self, link)\
      local id = link:match('youtu%.be/([^/]+)')\
      id = id or link:match('youtube.com/watch.*[?&]v=([^&]+)')\
      id = id or link:match('youtube.com/[ev]/([^/]+)')\
      id = id or link:match('youtube.com/embed/([^/]+)')\
      assert(id, \"couldn't parse youtube URL: '\" .. tostring(link) .. \"'\")\
      return iframe({\
        width = 560,\
        height = 315,\
        frameborder = 0,\
        allowfullscreen = true,\
        frameBorder = 0,\
        src = \"//www.youtube.com/embed/\" .. tostring(id)\
      })\
    end\
  },\
  {\
    inp = 'URL -> image/.+',\
    out = 'mmm/dom',\
    transform = function(self, src, fileder)\
      return img({\
        src = src\
      })\
    end\
  },\
  {\
    inp = 'URL -> video/.+',\
    out = 'mmm/dom',\
    transform = function(self, src)\
      return video((source({\
        src = src\
      })), {\
        controls = true,\
        loop = true\
      })\
    end\
  },\
  {\
    inp = 'text/plain',\
    out = 'mmm/dom',\
    transform = function(self, val)\
      return span(val)\
    end\
  },\
  {\
    inp = 'alpha',\
    out = 'mmm/dom',\
    transform = single(code)\
  },\
  {\
    inp = '(.+)',\
    out = 'URL -> %1',\
    transform = function(self, _, fileder, key)\
      return tostring(fileder.path) .. \"/\" .. tostring(key.name) .. \":\" .. tostring(self.from)\
    end\
  }\
}\
if MODE == 'SERVER' then\
  local ok, moon = pcall(require, 'moonscript.base')\
  if ok then\
    local _load = moon.load or moon.loadstring\
    table.insert(converts, {\
      inp = 'text/moonscript -> (.+)',\
      out = '%1',\
      transform = loadwith(moon.load or moon.loadstring)\
    })\
    table.insert(converts, {\
      inp = 'text/moonscript -> (.+)',\
      out = 'text/lua -> %1',\
      transform = single(moon.to_lua)\
    })\
  end\
else\
  table.insert(converts, {\
    inp = 'text/javascript -> (.+)',\
    out = '%1',\
    transform = function(self, source)\
      local f = js.new(window.Function, source)\
      return f()\
    end\
  })\
end\
do\
  local markdown\
  if MODE == 'SERVER' then\
    local success, discount = pcall(require, 'discount')\
    if not success then\
      warn(\"NO MARKDOWN SUPPORT!\", discount)\
    end\
    markdown = success and function(md)\
      local res = assert(discount.compile(md, 'githubtags'))\
      return res.body\
    end\
  else\
    markdown = window and window.marked and (function()\
      local _base_0 = window\
      local _fn_0 = _base_0.marked\
      return function(...)\
        return _fn_0(_base_0, ...)\
      end\
    end)()\
  end\
  if markdown then\
    table.insert(converts, {\
      inp = 'text/markdown',\
      out = 'text/html+frag',\
      transform = function(self, md)\
        return \"<div class=\\\"markdown\\\">\" .. tostring(markdown(md)) .. \"</div>\"\
      end\
    })\
    table.insert(converts, {\
      inp = 'text/markdown%+span',\
      out = 'mmm/dom',\
      transform = (function()\
        if MODE == 'SERVER' then\
          return function(self, source)\
            local html = markdown(source)\
            html = html:gsub('^<p', '<span')\
            return html:gsub('/p>$', '/span>')\
          end\
        else\
          return function(self, source)\
            local html = markdown(source)\
            html = html:gsub('^%s*<p>%s*', '')\
            html = html:gsub('%s*</p>%s*$', '')\
            do\
              local _with_0 = document:createElement('span')\
              _with_0.innerHTML = html\
              return _with_0\
            end\
          end\
        end\
      end)()\
    })\
  end\
end\
return converts\
", "mmm/mmmfs/converts.lua") end
if not p["mmm.mmmfs.layout"] then p["mmm.mmmfs.layout"] = load("local require = relative(..., 1)\
local header, aside, footer, div, svg, script, g, circle, h1, span, b, a, img\
do\
  local _obj_0 = require('mmm.dom')\
  header, aside, footer, div, svg, script, g, circle, h1, span, b, a, img = _obj_0.header, _obj_0.aside, _obj_0.footer, _obj_0.div, _obj_0.svg, _obj_0.script, _obj_0.g, _obj_0.circle, _obj_0.h1, _obj_0.span, _obj_0.b, _obj_0.a, _obj_0.img\
end\
local navigate_to\
navigate_to = (require('mmm.mmmfs.util'))(require('mmm.dom')).navigate_to\
local pick\
pick = function(...)\
  local num = select('#', ...)\
  local i = math.ceil(math.random() * num)\
  return (select(i, ...))\
end\
local iconlink\
iconlink = function(href, src, alt, style)\
  return a({\
    class = 'iconlink',\
    target = '_blank',\
    rel = 'me',\
    href = href,\
    img({\
      src = src,\
      alt = alt,\
      style = style\
    })\
  })\
end\
local logo = svg({\
  class = 'sun',\
  viewBox = '-0.75 -1 1.5 2',\
  xmlns = 'http://www.w3.org/2000/svg',\
  baseProfile = 'full',\
  version = '1.1',\
  g({\
    transform = 'translate(0 .18)',\
    g({\
      class = 'circle out',\
      circle({\
        r = '.6',\
        fill = 'none',\
        ['stroke-width'] = '.12'\
      })\
    }),\
    g({\
      class = 'circle  in',\
      circle({\
        r = '.2',\
        stroke = 'none'\
      })\
    })\
  })\
})\
local gen_header\
gen_header = function()\
  return header({\
    div({\
      h1({\
        navigate_to('', logo),\
        span({\
          span('mmm', {\
            class = 'bold'\
          }),\
          '&#8203;',\
          '.s&#8209;ol.nu'\
        })\
      }),\
      table.concat({\
        pick('fun', 'cool', 'weird', 'interesting', 'new', 'pleasant'),\
        pick('stuff', 'things', 'projects', 'experiments', 'visuals', 'ideas'),\
        pick(\"with\", 'and'),\
        pick('mostly code', 'code and wires', 'silicon', 'electronics', 'shaders', 'oscilloscopes', 'interfaces', 'hardware', 'FPGAs')\
      }, ' ')\
    }),\
    aside({\
      navigate_to('/about', 'about me'),\
      navigate_to('/games', 'games'),\
      navigate_to('/projects', 'other'),\
      a({\
        href = 'mailto:s%20[removethis]%20[at]%20s-ol.nu',\
        'contact',\
        script(\"\\n          var l = document.currentScript.parentElement;\\n          l.href = l.href.replace('%20[at]%20', '@');\\n          l.href = l.href.replace('%20[removethis]', '') + '?subject=Hey there :)';\\n        \")\
      })\
    })\
  })\
end\
footer = footer({\
  span({\
    'made with \\xe2\\x98\\xbd by ',\
    a('s-ol', {\
      href = 'https://twitter.com/S0lll0s'\
    }),\
    \", \" .. tostring(os.date('%Y'))\
  }),\
  div({\
    class = 'icons',\
    iconlink('https://github.com/s-ol', 'https://cdn.jsdelivr.net/npm/simple-icons@latest/icons/github.svg', 'github'),\
    iconlink('https://merveilles.town/@s_ol', 'https://cdn.jsdelivr.net/npm/simple-icons@latest/icons/mastodon.svg', 'mastodon'),\
    iconlink('https://twitter.com/S0lll0s', 'https://cdn.jsdelivr.net/npm/simple-icons@latest/icons/twitter.svg', 'twitter'),\
    iconlink('https://webring.xxiivv.com/#random', 'https://webring.xxiivv.com/icon.black.svg', 'webring', {\
      height = '1.3em',\
      ['margin-left'] = '.3em',\
      ['margin-top'] = '-0.12em'\
    })\
  })\
})\
local get_meta\
get_meta = function(self)\
  local title = (self:get('title: text/plain')) or self:gett('name: alpha')\
  local l\
  l = function(str)\
    str = str:gsub('[%s\\\\n]+$', '')\
    return str:gsub('\\\\n', ' ')\
  end\
  local e\
  e = function(str)\
    return string.format('%q', l(str))\
  end\
  local meta = \"\\n    <meta charset=\\\"UTF-8\\\">\\n    <title>\" .. tostring(l(title)) .. \"</title>\\n  \"\
  do\
    local page_meta = self:get('_meta: mmm/dom')\
    if page_meta then\
      meta = meta .. page_meta\
    else\
      meta = meta .. \"\\n    <meta name=\\\"viewport\\\" content=\\\"width=device-width, initial-scale=1\\\">\\n\\n    <meta property=\\\"og:title\\\" content=\" .. tostring(e(title)) .. \" />\\n    <meta property=\\\"og:type\\\"  content=\\\"website\\\" />\\n    <meta property=\\\"og:url\\\"   content=\\\"https://mmm.s-ol.nu\" .. tostring(self.path) .. \"/\\\" />\\n    <meta property=\\\"og:site_name\\\" content=\\\"mmm\\\" />\"\
      do\
        local desc = self:get('description: text/plain')\
        if desc then\
          meta = meta .. \"\\n    <meta property=\\\"og:description\\\" content=\" .. tostring(e(desc)) .. \" />\"\
        end\
      end\
    end\
  end\
  return meta\
end\
local render\
render = function(content, fileder, opts)\
  if opts == nil then\
    opts = { }\
  end\
  opts.meta = opts.meta or get_meta(fileder)\
  opts.scripts = opts.scripts or ''\
  if not (opts.noview) then\
    content = [[      <div class=\"view main\">\
        <div class=\"content\">\
      ]] .. content .. [[        </div>\
      </div>\
    ]]\
  end\
  local buf = [[<!DOCTYPE html>\
<html>\
  <head>\
    <link rel=\"stylesheet\" type=\"text/css\" href=\"/static/style/:text/css\" />\
    <link rel=\"stylesheet\" href=\"https://fonts.googleapis.com/css?family=Source+Sans+Pro:200,400,600\" />\
  ]]\
  buf = buf .. \"\\n    \" .. tostring(get_meta(fileder)) .. \"\\n  </head>\\n  <body>\\n    \" .. tostring(gen_header()) .. \"\\n\\n    \" .. tostring(content) .. \"\\n\\n    \" .. tostring(footer) .. \"\\n  \"\
  buf = buf .. [[    <script type=\"application/javascript\" src=\"/static/highlight-pack/:application/javascript\"></script>\
    <script type=\"application/javascript\" src=\"//cdnjs.cloudflare.com/ajax/libs/marked/0.5.1/marked.min.js\"></script>\
    <script type=\"application/javascript\" src=\"//cdnjs.cloudflare.com/ajax/libs/svg.js/2.6.6/svg.min.js\"></script>\
    <script type=\"application/javascript\" src=\"//platform.twitter.com/widgets.js\" charset=\"utf-8\"></script>\
    <script type=\"application/javascript\" src=\"/static/fengari-web/:application/javascript\"></script>\
    <script type=\"application/lua\" src=\"/static/mmm/:application/lua\"></script>\
    <script type=\"application/lua\">require 'mmm'</script>\
  ]]\
  buf = buf .. opts.scripts\
  buf = buf .. \"\\n  </body>\\n</html>\\n  \"\
  return buf\
end\
return {\
  render = render\
}\
", "mmm/mmmfs/layout.lua") end
if not p["mmm.mmmfs.stores.fs"] then p["mmm.mmmfs.stores.fs"] = load("local lfs = require('lfs')\
local dir_base\
dir_base = function(path)\
  local dir, base = path:match('(.-)([^/]-)$')\
  if dir and #dir > 0 then\
    dir = dir:sub(1, #dir - 1)\
  end\
  return dir, base\
end\
local FSStore\
do\
  local _class_0\
  local _base_0 = {\
    log = function(self, ...)\
      return print(\"[DB]\", ...)\
    end,\
    list_fileders_in = function(self, path)\
      if path == nil then\
        path = ''\
      end\
      return coroutine.wrap(function()\
        for entry_name in lfs.dir(self.root .. path) do\
          local _continue_0 = false\
          repeat\
            if '.' == entry_name:sub(1, 1) then\
              _continue_0 = true\
              break\
            end\
            local entry_path = self.root .. tostring(path) .. \"/\" .. tostring(entry_name)\
            if 'directory' == lfs.attributes(entry_path, 'mode') then\
              coroutine.yield(tostring(path) .. \"/\" .. tostring(entry_name))\
            end\
            _continue_0 = true\
          until true\
          if not _continue_0 then\
            break\
          end\
        end\
      end)\
    end,\
    list_all_fileders = function(self, path)\
      if path == nil then\
        path = ''\
      end\
      return coroutine.wrap(function()\
        for path in self:list_fileders_in(path) do\
          coroutine.yield(path)\
          for p in self:list_all_fileders(path) do\
            coroutine.yield(p)\
          end\
        end\
      end)\
    end,\
    create_fileder = function(self, parent, name)\
      self:log(\"creating fileder \" .. tostring(path))\
      local path = tostring(parent) .. \"/\" .. tostring(name)\
      assert(lfs.mkdir(self.root .. path))\
      return path\
    end,\
    remove_fileder = function(self, path)\
      self:log(\"removing fileder \" .. tostring(path))\
      local rmdir\
      rmdir = function(path)\
        for file in lfs.dir(path) do\
          local _continue_0 = false\
          repeat\
            if '.' == file:sub(1, 1) then\
              _continue_0 = true\
              break\
            end\
            local file_path = tostring(path) .. \"/\" .. tostring(file)\
            local _exp_0 = lfs.attributes(file_path, 'mode')\
            if 'file' == _exp_0 then\
              assert(os.remove(file_path))\
            elseif 'directory' == _exp_0 then\
              assert(rmdir(file_path))\
            end\
            _continue_0 = true\
          until true\
          if not _continue_0 then\
            break\
          end\
        end\
        return lfs.rmdir(path)\
      end\
      return rmdir(self.root .. path)\
    end,\
    rename_fileder = function(self, path, next_name)\
      self:log(\"renaming fileder \" .. tostring(path) .. \" -> '\" .. tostring(next_name) .. \"'\")\
      local parent, name = dir_base(path)\
      return assert(os.rename(path, self.root .. tostring(parent) .. \"/\" .. tostring(next_name)))\
    end,\
    move_fileder = function(self, path, next_parent)\
      self:log(\"moving fileder \" .. tostring(path) .. \" -> \" .. tostring(next_parent) .. \"/\")\
      local parent, name = dir_base(path)\
      return assert(os.rename(self.root .. path, self.root .. tostring(next_parent) .. \"/\" .. tostring(name)))\
    end,\
    list_facets = function(self, path)\
      return coroutine.wrap(function()\
        for entry_name in lfs.dir(self.root .. path) do\
          local entry_path = tostring(self.root .. path) .. \"/\" .. tostring(entry_name)\
          if 'file' == lfs.attributes(entry_path, 'mode') then\
            entry_name = (entry_name:match('(.*)%.%w+')) or entry_name\
            entry_name = entry_name:gsub('%$', '/')\
            local name, type = entry_name:match('([%w-_]+): *(.+)')\
            if not name then\
              name = ''\
              type = entry_name\
            end\
            coroutine.yield(name, type)\
          end\
        end\
      end)\
    end,\
    tofp = function(self, path, name, type)\
      if #name > 0 then\
        type = tostring(name) .. \": \" .. tostring(type)\
      end\
      type = type:gsub('%/', '$')\
      return self.root .. tostring(path) .. \"/\" .. tostring(type)\
    end,\
    locate = function(self, path, name, type)\
      if not (lfs.attributes(self.root .. path, 'mode')) then\
        return \
      end\
      type = type:gsub('%/', '$')\
      if #name > 0 then\
        name = tostring(name) .. \": \"\
      end\
      name = name .. type\
      name = name:gsub('([^%w])', '%%%1')\
      local file_name\
      for entry_name in lfs.dir(self.root .. path) do\
        if (entry_name:match(\"^\" .. tostring(name) .. \"$\")) or entry_name:match(\"^\" .. tostring(name) .. \"%.%w+$\") then\
          if file_name then\
            error(\"two files match \" .. tostring(name) .. \": \" .. tostring(file_name) .. \" and \" .. tostring(entry_name) .. \"!\")\
          end\
          file_name = entry_name\
        end\
      end\
      return file_name and self.root .. tostring(path) .. \"/\" .. tostring(file_name)\
    end,\
    load_facet = function(self, path, name, type)\
      local filepath = self:locate(path, name, type)\
      if not (filepath) then\
        return \
      end\
      local file = assert((io.open(filepath, 'rb')), \"couldn't open facet file '\" .. tostring(filepath) .. \"'\")\
      do\
        local _with_0 = file:read('*all')\
        file:close()\
        return _with_0\
      end\
    end,\
    create_facet = function(self, path, name, type, blob)\
      self:log(\"creating facet \" .. tostring(path) .. \" | \" .. tostring(name) .. \": \" .. tostring(type))\
      assert(blob, \"cant create facet without value!\")\
      local filepath = self:tofp(path, name, type)\
      if lfs.attributes(filepath, 'mode') then\
        error(\"facet file already exists!\")\
      end\
      local file = assert((io.open(filepath, 'wb')), \"couldn't open facet file '\" .. tostring(filepath) .. \"'\")\
      file:write(blob)\
      return file:close()\
    end,\
    remove_facet = function(self, path, name, type)\
      self:log(\"removing facet \" .. tostring(path) .. \" | \" .. tostring(name) .. \": \" .. tostring(type))\
      local filepath = self:locate(path, name, type)\
      assert(filepath, \"couldn't locate facet!\")\
      return assert(os.remove(filepath))\
    end,\
    rename_facet = function(self, path, name, type, next_name)\
      self:log(\"renaming facet \" .. tostring(path) .. \" | \" .. tostring(name) .. \": \" .. tostring(type) .. \" -> \" .. tostring(next_name))\
      local filepath = self:locate(path, name, type)\
      assert(filepath, \"couldn't locate facet!\")\
      return assert(os.rename(filepath, self:tofp(path, next_name, type)))\
    end,\
    update_facet = function(self, path, name, type, blob)\
      self:log(\"updating facet \" .. tostring(path) .. \" | \" .. tostring(name) .. \": \" .. tostring(type))\
      local filepath = self:locate(path, name, type)\
      assert(filepath, \"couldn't locate facet!\")\
      local file = assert((io.open(filepath, 'wb')), \"couldn't open facet file '\" .. tostring(filepath) .. \"'\")\
      file:write(blob)\
      return file:close()\
    end\
  }\
  _base_0.__index = _base_0\
  _class_0 = setmetatable({\
    __init = function(self, opts)\
      if opts == nil then\
        opts = { }\
      end\
      opts.root = opts.root or 'root'\
      opts.verbose = opts.verbose or false\
      if not opts.verbose then\
        self.log = function() end\
      end\
      self.root = opts.root:match('^(.-)/?$')\
      return self:log(\"opening '\" .. tostring(opts.root) .. \"'...\")\
    end,\
    __base = _base_0,\
    __name = \"FSStore\"\
  }, {\
    __index = _base_0,\
    __call = function(cls, ...)\
      local _self_0 = setmetatable({}, _base_0)\
      cls.__init(_self_0, ...)\
      return _self_0\
    end\
  })\
  _base_0.__class = _class_0\
  FSStore = _class_0\
end\
return {\
  FSStore = FSStore\
}\
", "mmm/mmmfs/stores/fs.lua") end
if not p["mmm.mmmfs.stores"] then p["mmm.mmmfs.stores"] = load("local require = relative(..., 0)\
local get_store\
get_store = function(args, opts)\
  if args == nil then\
    args = 'sql'\
  end\
  if opts == nil then\
    opts = {\
      verbose = true\
    }\
  end\
  local type, arg = args:match('(%w+):(.*)')\
  if not (type) then\
    type = args\
  end\
  local _exp_0 = type:lower()\
  if 'sql' == _exp_0 then\
    local SQLStore\
    SQLStore = require('.sql').SQLStore\
    if arg == 'MEMORY' then\
      opts.memory = true\
    else\
      opts.file = arg\
    end\
    return SQLStore(opts)\
  elseif 'fs' == _exp_0 then\
    local FSStore\
    FSStore = require('.fs').FSStore\
    opts.root = arg\
    return FSStore(opts)\
  else\
    warn(\"unknown or missing value for STORE: valid types values are sql, fs\")\
    return os.exit(1)\
  end\
end\
return {\
  get_store = get_store\
}\
", "mmm/mmmfs/stores/init.lua") end
if not p["mmm.mmmfs.stores.sql"] then p["mmm.mmmfs.stores.sql"] = load("local sqlite = require('sqlite3')\
local root = os.tmpname()\
local SQLStore\
do\
  local _class_0\
  local _base_0 = {\
    log = function(self, ...)\
      return print(\"[DB]\", ...)\
    end,\
    close = function(self)\
      return self.db:close()\
    end,\
    fetch = function(self, q, ...)\
      local stmt = assert(self.db:prepare(q))\
      if 0 < select('#', ...) then\
        stmt:bind(...)\
      end\
      return stmt:irows()\
    end,\
    fetch_one = function(self, q, ...)\
      local stmt = assert(self.db:prepare(q))\
      if 0 < select('#', ...) then\
        stmt:bind(...)\
      end\
      return stmt:first_irow()\
    end,\
    exec = function(self, q, ...)\
      local stmt = assert(self.db:prepare(q))\
      if 0 < select('#', ...) then\
        stmt:bind(...)\
      end\
      local res = assert(stmt:exec())\
    end,\
    list_fileders_in = function(self, path)\
      if path == nil then\
        path = ''\
      end\
      return coroutine.wrap(function()\
        for _des_0 in self:fetch('SELECT path\\n                              FROM fileder WHERE parent IS ?', path) do\
          path = _des_0[1]\
          coroutine.yield(path)\
        end\
      end)\
    end,\
    list_all_fileders = function(self, path)\
      if path == nil then\
        path = ''\
      end\
      return coroutine.wrap(function()\
        for path in self:list_fileders_in(path) do\
          coroutine.yield(path)\
          for p in self:list_all_fileders(path) do\
            coroutine.yield(p)\
          end\
        end\
      end)\
    end,\
    create_fileder = function(self, parent, name)\
      local path = tostring(parent) .. \"/\" .. tostring(name)\
      self:log(\"creating fileder \" .. tostring(path))\
      self:exec('INSERT INTO fileder (path, parent)\\n           VALUES (:path, :parent)', {\
        path = path,\
        parent = parent\
      })\
      local changes = self:fetch_one('SELECT changes()')\
      assert(changes[1] == 1, \"couldn't create fileder - parent missing?\")\
      return path\
    end,\
    remove_fileder = function(self, path)\
      self:log(\"removing fileder \" .. tostring(path))\
      return self:exec('DELETE FROM fileder\\n           WHERE path LIKE :path || \"/%\"\\n              OR path = :path', path)\
    end,\
    rename_fileder = function(self, path, next_name)\
      self:log(\"renaming fileder \" .. tostring(path) .. \" -> '\" .. tostring(next_name) .. \"'\")\
      error('not implemented')\
      return self:exec('UPDATE fileder\\n           SET path = parent || \"/\" || :next_name\\n           WHERE path = :path', {\
        path = path,\
        next_name = next_name\
      })\
    end,\
    move_fileder = function(self, path, next_parent)\
      self:log(\"moving fileder \" .. tostring(path) .. \" -> \" .. tostring(next_parent) .. \"/\")\
      return error('not implemented')\
    end,\
    list_facets = function(self, path)\
      return coroutine.wrap(function()\
        for _des_0 in self:fetch('SELECT facet.name, facet.type\\n                                    FROM facet\\n                                    INNER JOIN fileder ON facet.fileder_id = fileder.id\\n                                    WHERE fileder.path = ?', path) do\
          local name, type\
          name, type = _des_0[1], _des_0[2]\
          coroutine.yield(name, type)\
        end\
      end)\
    end,\
    load_facet = function(self, path, name, type)\
      local v = self:fetch_one('SELECT facet.value\\n                    FROM facet\\n                    INNER JOIN fileder ON facet.fileder_id = fileder.id\\n                    WHERE fileder.path = :path\\n                      AND facet.name = :name\\n                      AND facet.type = :type', {\
        path = path,\
        name = name,\
        type = type\
      })\
      return v and v[1]\
    end,\
    create_facet = function(self, path, name, type, blob)\
      self:log(\"creating facet \" .. tostring(path) .. \" | \" .. tostring(name) .. \": \" .. tostring(type))\
      self:exec('INSERT INTO facet (fileder_id, name, type, value)\\n           SELECT id, :name, :type, :blob\\n           FROM fileder\\n           WHERE fileder.path = :path', {\
        path = path,\
        name = name,\
        type = type,\
        blob = blob\
      })\
      local changes = self:fetch_one('SELECT changes()')\
      return assert(changes[1] == 1, \"couldn't create facet - fileder missing?\")\
    end,\
    remove_facet = function(self, path, name, type)\
      self:log(\"removing facet \" .. tostring(path) .. \" | \" .. tostring(name) .. \": \" .. tostring(type))\
      self:exec('DELETE FROM facet\\n           WHERE name = :name\\n             AND type = :type\\n             AND fileder_id = (SELECT id FROM fileder WHERE path = :path)', {\
        path = path,\
        name = name,\
        type = type\
      })\
      local changes = self:fetch_one('SELECT changes()')\
      return assert(changes[1] == 1, \"no such facet\")\
    end,\
    rename_facet = function(self, path, name, type, next_name)\
      self:log(\"renaming facet \" .. tostring(path) .. \" | \" .. tostring(name) .. \": \" .. tostring(type) .. \" -> \" .. tostring(next_name))\
      self:exec('UPDATE facet\\n           SET name = :next_name\\n           WHERE name = :name\\n             AND type = :type\\n             AND fileder_id = (SELECT id FROM fileder WHERE path = :path)', {\
        path = path,\
        name = name,\
        next_name = next_name,\
        type = type\
      })\
      local changes = self:fetch_one('SELECT changes()')\
      return assert(changes[1] == 1, \"no such facet\")\
    end,\
    update_facet = function(self, path, name, type, blob)\
      self:log(\"updating facet \" .. tostring(path) .. \" | \" .. tostring(name) .. \": \" .. tostring(type))\
      self:exec('UPDATE facet\\n           SET value = :blob\\n           WHERE facet.name = :name\\n             AND facet.type = :type\\n             AND facet.fileder_id = (SELECT id FROM fileder WHERE path = :path)', {\
        path = path,\
        name = name,\
        type = type,\
        blob = blob\
      })\
      local changes = self:fetch_one('SELECT changes()')\
      return assert(changes[1] == 1, \"no such facet\")\
    end\
  }\
  _base_0.__index = _base_0\
  _class_0 = setmetatable({\
    __init = function(self, opts)\
      if opts == nil then\
        opts = { }\
      end\
      opts.file = opts.file or 'db.sqlite3'\
      opts.verbose = opts.verbose or false\
      opts.memory = opts.memory or false\
      if not opts.verbose then\
        self.log = function() end\
      end\
      if opts.memory then\
        self:log(\"opening in-memory DB...\")\
        self.db = sqlite.open_memory()\
      else\
        self:log(\"opening '\" .. tostring(opts.file) .. \"'...\")\
        self.db = sqlite.open(opts.file)\
      end\
      return assert(self.db:exec([[      PRAGMA foreign_keys = ON;\
      PRAGMA case_sensitive_like = ON;\
      CREATE TABLE IF NOT EXISTS fileder (\
        id INTEGER NOT NULL PRIMARY KEY,\
        path TEXT NOT NULL UNIQUE,\
        parent TEXT REFERENCES fileder(path)\
                      ON DELETE CASCADE\
                      ON UPDATE CASCADE\
      );\
      INSERT OR IGNORE INTO fileder (path, parent) VALUES (\"\", NULL);\
\
      CREATE TABLE IF NOT EXISTS facet (\
        fileder_id INTEGER NOT NULL\
                   REFERENCES fileder\
                     ON UPDATE CASCADE\
                     ON DELETE CASCADE,\
        name TEXT NOT NULL,\
        type TEXT NOT NULL,\
        value BLOB NOT NULL,\
        PRIMARY KEY (fileder_id, name, type)\
      );\
      CREATE INDEX IF NOT EXISTS facet_fileder_id ON facet(fileder_id);\
      CREATE INDEX IF NOT EXISTS facet_name ON facet(name);\
    ]]))\
    end,\
    __base = _base_0,\
    __name = \"SQLStore\"\
  }, {\
    __index = _base_0,\
    __call = function(cls, ...)\
      local _self_0 = setmetatable({}, _base_0)\
      cls.__init(_self_0, ...)\
      return _self_0\
    end\
  })\
  _base_0.__class = _class_0\
  SQLStore = _class_0\
end\
return {\
  SQLStore = SQLStore\
}\
", "mmm/mmmfs/stores/sql.lua") end
if not p["mmm.dom"] then p["mmm.dom"] = load("local element\
element = function(element)\
  return function(...)\
    local children = {\
      ...\
    }\
    local attributes = children[#children]\
    if 'table' == (type(attributes)) and not attributes.node then\
      table.remove(children)\
    else\
      attributes = { }\
    end\
    do\
      local e = document:createElement(element)\
      for k, v in pairs(attributes) do\
        if k == 'class' then\
          k = 'className'\
        end\
        if k == 'style' and 'table' == type(v) then\
          for kk, vv in pairs(v) do\
            e.style[kk] = vv\
          end\
        elseif 'string' == type(k) then\
          e[k] = v\
        end\
      end\
      if #children == 0 then\
        children = attributes\
      end\
      for _index_0 = 1, #children do\
        local child = children[_index_0]\
        if 'string' == type(child) then\
          child = document:createTextNode(child)\
        end\
        e:appendChild(child)\
      end\
      return e\
    end\
  end\
end\
return setmetatable({ }, {\
  __index = function(self, name)\
    do\
      local val = element(name)\
      self[name] = val\
      return val\
    end\
  end\
})\
", "mmm/dom/init.client.lua") end
if not p["mmm.component"] then p["mmm.component"] = load("local tohtml\
tohtml = function(val)\
  if 'string' == type(val) then\
    return document:createTextNode(val)\
  end\
  if 'table' == type(val) then\
    assert(val.node, \"Table doesn't have .node\")\
    val = val.node\
  end\
  if 'userdata' == type(val) then\
    assert((js.instanceof(val, js.global.Node)), \"userdata is not a Node\")\
    return val\
  else\
    return error(\"not a Node: \" .. tostring(val) .. \", \" .. tostring(type(val)))\
  end\
end\
local text\
text = function(str)\
  return document:createTextNode(tostring(str))\
end\
local ReactiveVar\
do\
  local _class_0\
  local _base_0 = {\
    set = function(self, value)\
      local old = self.value\
      self.value = value\
      for k, callback in pairs(self.listeners) do\
        callback(self.value, old)\
      end\
    end,\
    get = function(self)\
      return self.value\
    end,\
    transform = function(self, transform)\
      return self:set(transform(self:get()))\
    end,\
    subscribe = function(self, callback)\
      do\
        local _with_0\
        _with_0 = function()\
          self.listeners[callback] = nil\
        end\
        self.listeners[callback] = callback\
        return _with_0\
      end\
    end,\
    map = function(self, transform)\
      do\
        local _with_0 = ReactiveVar(transform(self.value))\
        _with_0.upstream = self:subscribe(function(...)\
          return _with_0:set(transform(...))\
        end)\
        return _with_0\
      end\
    end\
  }\
  _base_0.__index = _base_0\
  _class_0 = setmetatable({\
    __init = function(self, value)\
      self.value = value\
      self.listeners = setmetatable({ }, {\
        __mode = 'kv'\
      })\
    end,\
    __base = _base_0,\
    __name = \"ReactiveVar\"\
  }, {\
    __index = _base_0,\
    __call = function(cls, ...)\
      local _self_0 = setmetatable({}, _base_0)\
      cls.__init(_self_0, ...)\
      return _self_0\
    end\
  })\
  _base_0.__class = _class_0\
  local self = _class_0\
  self.isinstance = function(val)\
    return 'table' == (type(val)) and val.subscribe\
  end\
  ReactiveVar = _class_0\
end\
local ReactiveElement\
do\
  local _class_0\
  local _base_0 = {\
    destroy = function(self)\
      local _list_0 = self._subscriptions\
      for _index_0 = 1, #_list_0 do\
        local unsub = _list_0[_index_0]\
        unsub()\
      end\
    end,\
    set = function(self, attr, value)\
      if attr == 'class' then\
        attr = 'className'\
      end\
      if 'table' == (type(value)) and ReactiveVar.isinstance(value) then\
        table.insert(self._subscriptions, value:subscribe(function(...)\
          return self:set(attr, ...)\
        end))\
        value = value:get()\
      end\
      if attr == 'style' and 'table' == type(value) then\
        for k, v in pairs(value) do\
          self.node.style[k] = v\
        end\
        return \
      end\
      self.node[attr] = value\
    end,\
    prepend = function(self, child, last)\
      return self:append(child, last, 'prepend')\
    end,\
    append = function(self, child, last, mode)\
      if mode == nil then\
        mode = 'append'\
      end\
      if ReactiveVar.isinstance(child) then\
        table.insert(self._subscriptions, child:subscribe(function(...)\
          return self:append(...)\
        end))\
        child = child:get()\
      end\
      if 'string' == type(last) then\
        error('cannot replace string node')\
      end\
      if child == nil then\
        if last then\
          self:remove(last)\
        end\
        return \
      end\
      child = tohtml(child)\
      if last then\
        return self.node:replaceChild(child, tohtml(last))\
      else\
        local _exp_0 = mode\
        if 'append' == _exp_0 then\
          return self.node:appendChild(child)\
        elseif 'prepend' == _exp_0 then\
          return self.node:insertBefore(child, self.node.firstChild)\
        end\
      end\
    end,\
    remove = function(self, child)\
      self.node:removeChild(tohtml(child))\
      if 'table' == (type(child)) and child.destroy then\
        return child:destroy()\
      end\
    end\
  }\
  _base_0.__index = _base_0\
  _class_0 = setmetatable({\
    __init = function(self, element, ...)\
      if 'userdata' == type(element) then\
        self.node = element\
      else\
        self.node = document:createElement(element)\
      end\
      self._subscriptions = { }\
      local children = {\
        ...\
      }\
      local attributes = children[#children]\
      if 'table' == (type(attributes)) and (not ReactiveElement.isinstance(attributes)) and (not ReactiveVar.isinstance(attributes)) then\
        table.remove(children)\
      else\
        attributes = { }\
      end\
      for k, v in pairs(attributes) do\
        if 'string' == type(k) then\
          self:set(k, v)\
        end\
      end\
      if #children == 0 then\
        children = attributes\
      end\
      for _index_0 = 1, #children do\
        local child = children[_index_0]\
        self:append(child)\
      end\
    end,\
    __base = _base_0,\
    __name = \"ReactiveElement\"\
  }, {\
    __index = _base_0,\
    __call = function(cls, ...)\
      local _self_0 = setmetatable({}, _base_0)\
      cls.__init(_self_0, ...)\
      return _self_0\
    end\
  })\
  _base_0.__class = _class_0\
  local self = _class_0\
  self.isinstance = function(val)\
    return 'table' == (type(val)) and val.node\
  end\
  ReactiveElement = _class_0\
end\
local get_or_create\
get_or_create = function(elem, id, ...)\
  elem = (document:getElementById(id)) or elem\
  do\
    local _with_0 = ReactiveElement(elem, ...)\
    _with_0:set('id', id)\
    return _with_0\
  end\
end\
local elements = setmetatable({ }, {\
  __index = function(self, name)\
    do\
      local val\
      val = function(...)\
        return ReactiveElement(name, ...)\
      end\
      self[name] = val\
      return val\
    end\
  end\
})\
return {\
  ReactiveVar = ReactiveVar,\
  ReactiveElement = ReactiveElement,\
  get_or_create = get_or_create,\
  tohtml = tohtml,\
  text = text,\
  elements = elements\
}\
", "mmm/component/init.client.lua") end
