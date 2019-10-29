import div, button from require 'mmm.dom'
import languages from require 'mmm.highlighting'

class Editor
  o = if MODE == 'CLIENT'
    mkobj = window\eval "(function () { return {}; })"
    (tbl) ->
      with obj = mkobj!
        for k,v in pairs(tbl)
          obj[k] = v

  new: (value, mode, @fileder, @key) =>
    @node = div {
      class: 'editor'
      style:
        display: 'flex'
        'flex-direction': 'column'
        'justify-content': 'space-around'

      div {
        style:
          display: 'flex'
          flex: '0'
          'justify-content': 'flex-end'
          'border-bottom': '2px solid var(--gray-dark)'
          'padding-bottom': '0.5em'
          'margin': '-0.5em 0 0.5em'

        with @saveBtn = button 'save changes'
          .disabled = true
          .onclick = (_, e) -> @save e
      }
    }
    @cm = window\CodeMirror @node, o {
      :value
      :mode
      lineNumber: true
      lineWrapping: true
      autoRefresh: true
      theme: 'hybrid'
    }

    @lastSave = @cm\getDoc!\changeGeneration true

    @cm\on 'changes', (_, mirr) ->
      doc = @cm\getDoc!
      @saveBtn.disabled = doc\isClean @lastSave

      window\clearTimeout @timeout if @timeout
      @timeout = window\setTimeout (-> @change!), 300

  change: =>
    @timeout = nil
    doc = @cm\getDoc!

    if @lastPreview and doc\isClean @lastPreview
      -- no changes since last event
      return
    
    @lastPreview = doc\changeGeneration!
    value = doc\getValue!

    @fileder.facets[@key] = value
    BROWSER\refresh!

  save: (e) =>
    e\preventDefault!

    doc = @cm\getDoc!
    @fileder\set @key, doc\getValue!
    @lastSave = doc\changeGeneration true

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
