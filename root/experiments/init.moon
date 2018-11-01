import div, h3, ul, li, a from require 'lib.dom'
import define_fileders from require 'lib.mmmfs'
Fileder = define_fileders ...
require = relative ...

Fileder {
  'name: alpha': 'experiments',
  'title: text/plain': 'various experiments',
  'moon -> mmm/dom': (path) => div {
      h3 @gett 'title: text/plain', style: { 'margin-bottom': '-.5em' },
      ul for child in *@children
        name = child\gett 'name: alpha'
        desc = child\gett 'description: text/plain'
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

  require '.center_of_mass'
  require '.tags'
}
