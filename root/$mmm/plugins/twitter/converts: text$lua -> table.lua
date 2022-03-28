local div, blockquote, a
do
  local _obj_0 = require('mmm.dom')
  div, blockquote, a = _obj_0.div, _obj_0.blockquote, _obj_0.a
end
local iframe
iframe = require('mmm.dom').iframe
return {
  {
    inp = 'URL -> twitter/tweet',
    out = 'mmm/dom',
    cost = -4,
    transform = function(self, href)
      local user, id = assert((href:match('twitter.com/([^/]-)/status/(%d*)')), "couldn't parse twitter/tweet URL: '" .. tostring(href) .. "'")
      return iframe({
        width = 550,
        height = 560,
        border = 0,
        frameBorder = 0,
        allowfullscreen = true,
        src = "//twitframe.com/show?url=https%3A%2F%2Ftwitter.com%2F" .. tostring(user) .. "%2F" .. tostring(id)
      })
    end
  }
}
