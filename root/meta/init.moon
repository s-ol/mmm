import div, h3, p, br, ul, li, b, a from require 'mmm.dom'
import define_fileders from require 'mmm.mmmfs'
Fileder = define_fileders ...
require = relative ...

Fileder {
  'name: alpha': 'meta',
  'title: text/plain': 'about mmm',
  'fn -> mmm/dom': (path) => div {
      style: { 'max-width': '700px' },
      h3 @gett 'title: text/plain', style: { 'margin-bottom': '-.5em' },
      p "mmm is a collection of Lua/Moonscript modules for web development.",
        "All modules are 'polymorphic' - they can run in the ", (b 'browser'),
        ", using the native browser API for creating and interacting with DOM content, as well as on the ",
        (b 'server'), ", where they operate on and produce equivalent HTML strings."
      p "As the two implementations of each module are designed to be compatible,
        mmm facilitates code and content sharing between server and client
        and enables serverside rendering and rehydration."
      ul for child in *@children
        name = child\gett 'name: alpha'
        desc = child\gett 'description: mmm/dom'
        li {
          a name, {
            href: child.path,
            onclick: (e) =>
              e\preventDefault!
              BROWSER\navigate child.path
          },
          ': ', desc
        }
    }

  require '.mmm_dom'
  require '.todo'
  require '.test_component'
}
