require = relative ...
import Key, Fileder from require '.fileder'
import Browser from require '.browser'
import tohtml from require 'lib.component'

define_fileders = (...) ->
  source_module = ...

  (...) ->
    with fileder = Fileder ...
      .source_module = source_module

rehydrate = (path) ->
  import Browser from require 'lib.mmmfs.browser'
  root = require 'root'
  root\mount!

  export BROWSER
  BROWSER = Browser root, path, true

render = (root, path) ->
  export BROWSER
  BROWSER = Browser root, path

  content = tohtml BROWSER
  content, on_client rehydrate, path

{
  :Key
  :Fileder
  :render
  :define_fileders
  :module_roots
}
