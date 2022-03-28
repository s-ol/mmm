if not (window and window.mermaid) then
  return 
end
window.mermaid:initialize({
  startOnLoad = false,
  fontFamily = 'monospace'
})
local id_counter = 1
return {
  {
    inp = 'text/mermaid-graph',
    out = 'mmm/dom',
    cost = 1,
    transform = function(self, source, fileder, key)
      id_counter = id_counter + 1
      local id = "mermaid-" .. tostring(id_counter)
      do
        local container = document:createElement('div')
        local cb
        cb = function(self, svg)
          container.innerHTML = svg
          container.firstElementChild.style.width = '100%'
          container.firstElementChild.style.height = 'auto'
        end
        window:setImmediate(function(_)
          return window.mermaid:render(id, source, cb, container)
        end)
        return container
      end
    end
  }
}
