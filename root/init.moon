import define_fileders from require 'mmm.mmmfs'
Fileder = define_fileders ...
require = relative ...

Fileder {
  'name: alpha': '',
  'fn -> mmm/dom': =>
    import article, h1, h3, div, b, p, a, br, ul, tt, li, img from require 'mmm.dom'
    import opairs from require 'mmm.ordered'

    append, finish = do
      content = {}

      append = (stuff) -> table.insert content, stuff
      append, -> article content

    moon = '\xe2\x98\xbd'

    iconlink = (href, src, alt, style) -> a {
      class: 'iconlink',
      :href,
      target: '_blank',
      img :src, :alt, :style
    }

    -- menu
    append h1 {
      style: {
        position: 'relative',
        'border-bottom': '1px solid #000'
      },
      'mmm',
      div {
        class: 'icons',
        iconlink 'https://github.com/s-ol/mmm', 'https://cdn.jsdelivr.net/npm/simple-icons@latest/icons/github.svg',
        iconlink 'https://twitter.com/S0lll0s', 'https://cdn.jsdelivr.net/npm/simple-icons@latest/icons/twitter.svg',
        iconlink 'https://webring.xxiivv.com/#random', 'https://webring.xxiivv.com/icon.black.svg', 'webring',
          { height: '0.9em', 'margin-left': '.04em' }
      }
    }

    append p {
      tt 'mmm'
      ' is not the '
      tt 'www'
      ', because it runs on '
      a { 'MoonScript', href: 'https://moonscript.org' }
      '.'
      br!
      'You can find the source code of everything '
      a { 'here', href: 'https://github.com/s-ol/mmm' }
      '.'
    }

    for child in *@children
      append (child\get 'preview: mmm/dom') or child\get 'mmm/dom'

    append p {
      "made with #{moon} by "
      a { 's-ol', href: 'https://twitter.com/S0lll0s' }
    }

    finish!

  require '.articles'
  require '.animations'
  require '.experiments'
  require '.meta'
}
