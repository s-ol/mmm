import div from require 'mmm.dom'
import languages from require 'mmm.highlighting'

class Editor
  o = do
    mkobj = window\eval "(function () { return {}; })"
    (tbl) ->
      with obj = mkobj!
        for k,v in pairs(tbl)
          obj[k] = v

  new: (value, mode, @fileder, @key) =>
    @node = div class: 'editor'
    @cm = window\CodeMirror @node, o {
      :value
      :mode
      lineNumber: true
      lineWrapping: true
      autoRefresh: true
      theme: 'hybrid'
    }

    @cm\on 'changes', (_, mirr) ->
      window\clearTimeout @timeout if @timeout
      @timeout = window\setTimeout (-> @change!), 300

  change: =>
    @timeout = nil
    doc = @cm\getDoc!
    if @lastState and doc\isClean @lastState
      -- no changes since last event
      return
    
    @lastState = doc\changeGeneration true
    value = doc\getValue!

    @fileder.facets[@key] = value
    BROWSER\refresh!

-- syntax-highlighted code
{
  converts: {
    {
      inp: 'text/([^ ]*).*'
      out: 'mmm/dom'
      cost: 5
      transform: (val) =>
        lang = @from\match @convert.inp
        pre languages[lang] val
    }
  }
  editors: if MODE == 'CLIENT' then {
    {
      inp: 'text/([^ ]*).*'
      out: 'mmm/dom'
      cost: 0
      transform: (value, fileder, key) =>
        mode = @from\match @convert.inp
        Editor value, mode, fileder, key
    }
  }
}
