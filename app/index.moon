on_client ->
  import h1, p, a, br, ul, tt, li from require 'lib.html'

  moon = '\xe2\x98\xbd'
  demos =
    'twisted': 'canvas animation',
    'todo': 'Todo demo of a simple reactive UI framework',
    'realities': 'draft of a paper on virtual and other realities',
    'center_of_mass': 'aligning characters by their centers of mass',
    'test_component': 'Test suite for the UI framework',
    'tags': 'Playground for Functional Tags',

  redirs =
    'center-of-mass': 'center_of_mass',
    'test-component': 'test_component',
    'play-tags': 'tags',

  back_button = ->
    append p a { '< back', href: '/' }

  if window.location.search and #window.location.search > 1
    name = window.location.search\sub 2
    window.location.href = "#{redirs[name] or name}.html"
  else
    append h1 'mmm'
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
    append p 'current demos:'
    append ul for name, desc in pairs demos
      li (a name, href: "/#{name}.html"), ': ', desc

  append p {
    "made with #{moon} by "
    a { 's-ol', href: 'https://twitter.com/S0lll0s' }
  }
