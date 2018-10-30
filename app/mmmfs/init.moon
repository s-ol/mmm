require = relative ...

render = (path) ->
  import Browser from require 'lib.mmmfs.browser'
  import tohtml from require 'lib.component'
  root = require '.tree'

  export BROWSER
  BROWSER = Browser root, path
  append tohtml BROWSER

  if MODE == 'SERVER'
    rehydrate = (path) ->
      require = relative ...

      import Browser from require 'lib.mmmfs.browser'
      root = require '.tree'

      export BROWSER
      BROWSER = Browser root, path, true
      window.hljs\initHighlightingOnLoad!

  on_client init, path
