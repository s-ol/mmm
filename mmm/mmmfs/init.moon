require = relative ...
import Key, Fileder from require '.fileder'
import Browser from require '.browser'
import tohtml from require 'mmm.component'

render = (root, path) ->
  export BROWSER
  BROWSER = Browser root, path

  content = tohtml BROWSER

  rehydrate = "
<script type=\"application/lua\">
  on_load = on_load or {}
  table.insert(on_load, function()
    local path = #{string.format '%q', path}
    local browser = require 'mmm.mmmfs.browser'
    local root = require 'root'
    root:mount()

    BROWSER = browser.Browser(root, path, true)
  end)
</script>"
  content, rehydrate

{
  :Key
  :Fileder
  :Browser
  :render
}
