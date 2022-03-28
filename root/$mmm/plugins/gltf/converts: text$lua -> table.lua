local dom = require('mmm.dom')
return {
  {
    inp = 'URL -> model/gltf-binary',
    out = 'mmm/dom',
    cost = 1,
    transform = function(self, href)
      return dom['model-viewer']({
        src = href,
        ['auto-rotate'] = true,
        ['camera-controls'] = true,
        ['camera-orbit'] = "548.2deg 117deg 282.4m"
      })
    end
  }
}
