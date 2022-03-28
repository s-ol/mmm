local iframe
iframe = require('mmm.dom').iframe
return {
  {
    inp = 'URL -> youtube/video',
    out = 'mmm/dom',
    cost = -4,
    transform = function(self, link)
      local id = link:match('youtu%.be/([^/]+)')
      id = id or link:match('youtube.com/watch.*[?&]v=([^&]+)')
      id = id or link:match('youtube.com/[ev]/([^/]+)')
      id = id or link:match('youtube.com/embed/([^/]+)')
      assert(id, "couldn't parse youtube URL: '" .. tostring(link) .. "'")
      return iframe({
        width = 560,
        height = 315,
        border = 0,
        frameborder = 0,
        allowfullscreen = true,
        src = "//www.youtube.com/embed/" .. tostring(id)
      })
    end
  }
}
