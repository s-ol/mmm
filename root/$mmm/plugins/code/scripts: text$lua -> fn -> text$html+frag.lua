local tourl
tourl = (require('mmm.mmmfs.util'))({ }).tourl
return function(self)
  return "\n  <link rel=\"stylesheet\" type=\"text/css\" href=\"" .. tostring(self:gett('style: URL -> text/css')) .. "\" />" .. [[<!--
  <link rel="stylesheet" type="text/css" href="//unpkg.com/codemirror@5.49.2/lib/codemirror.css" />
  <script type="text/javascript" src="//unpkg.com/codemirror@5.49.2/lib/codemirror.js"></script>
  <script type="text/javascript" src="//unpkg.com/codemirror@5.49.2/mode/lua/lua.js"></script>
  <script type="text/javascript" src="//unpkg.com/codemirror@5.49.2/mode/markdown/markdown.js"></script>
  <script type="text/javascript" src="//unpkg.com/codemirror@5.49.2/addon/display/autorefresh.js"></script>
-->
  ]]
end
