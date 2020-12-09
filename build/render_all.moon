add = (tmpl) ->
  package.path ..= ";#{tmpl}.lua"
  package.moonpath ..= ";#{tmpl}.moon"

add '?'
add '?.server'
add '?/init'
add '?/init.server'

-- usage:
-- moon render_all.moon [STORE] [output] [URL-prefix]
{ store, output, prefix } = arg

export UNSAFE, STATIC

UNSAFE = true
STATIC = {
  spit: (path, val) ->
    path = "#{output}/#{path}"
    os.execute "mkdir -p '#{dir_base path}'"
    with io.open path, 'w'
      \write val
      \close!

  root: prefix
}

require 'mmm'
import Fileder, dir_base from require 'mmm.mmmfs.fileder'
import get_store from require 'mmm.mmmfs.stores'

store = get_store store
root = Fileder store

print "rendering to #{output}"

style_url = (root\walk '/static/style')\gett 'URL -> text/css'
hljs_url = (root\walk '/static/highlight-pack')\gett 'URL -> text/javascript'
STATIC.style = "<link rel=\"stylesheet\" type=\"text/css\" href=\"#{style_url}\" />"
STATIC.scripts = "
    <script type=\"text/javascript\" src=\"#{hljs_url}\"></script>
    <script type=\"text/javascript\">hljs.initHighlighting()</script>"

tree = root\walk startpath or ''

for fileder in coroutine.wrap tree\iterate
  print "rendering '#{fileder.path}'..."

  ok, val = pcall fileder.gett, fileder, 'text/html'
  if not ok
    warn "WARN: couldn't render #{fileder}:"
    warn val

  STATIC.spit "#{fileder.path}/index.html", val
