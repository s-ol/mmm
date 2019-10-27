Today I finally reached the ability of editing content inside of mmmfs directly!

<mmm-embed path="video" nolink></mmm-embed>

Content is currently not saved anywhere, but the basis of the feature is there.
For the moment this is implemented as yeat another *convert* that simply converts
from `text/.*` (any textual code) to `mmm/dom` (web UI) \[[`28653c9`][28653c9]\].
However this *convert* is only applied in the inspector view (more on that below).
First, here is the convert itself:

    {
      inp: 'text/([^ ]*).*'
      out: 'mmm/dom'
      cost: 0
      transform: (value, fileder, key) =>
        mode = @from\match @convert.inp
        Editor value, mode, fileder, key
    }

and the main part of the code, the `Editor` widget:

    class Editor
      new: (value, mode, @fileder, @key) =>
        @node = div class: 'editor'
        -- 'o' is a little helper for converting a Lua table to a JS object
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

I chose the [CodeMirror][codemirror] library as the basis for the editor,
because it seemed like one of the leanest ones I could find
(and yet it is quite heavy at 100kb plus styling and language support addons).
The code for the editor is also quite minimale it really just creates a wrapper for the editor
and tells CodeMirror to set itself up inside.
Whenever changes are detected, a timeout of 300ms is started,
after which the preview is refreshed to preview the changes.
If more changes are made within the 300ms, the timer is reset to 300ms,
so that the preview update doesn't interrupt the typing flow.

I also spent some time refactoring the global list of converts out into multiple smaller plugins
(although a lot of global converts remain at the moment) \[[`abefbf8`][abefbf8]\].
A plugin can export a list of converts as well as a list of 'editors', which are essentially no different,
except that they are taken into consideration only when converting content for the inspector. 

Breaking the converts up into little packages like that makes it a lot easier to edit,
and allows enabling and disabling individual features very easily.
I am also considering moving the converts into the mmmfs data itself,
to make extending the system and working inside the system more congruent,
and this is a good way of testing my idea of how the modularization of the system should work.

[codemirror]: https://codemirror.net/
[28653c9]: https://git.s-ol.nu/mmm/commit/28653c9ae46b2b3e42c2c75879589138c731f37b/
[abefbf8]: https://git.s-ol.nu/mmm/commit/abefbf82531021f5ca4149675932a7fe2ff37dde/
