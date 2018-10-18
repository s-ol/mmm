require = relative ...

on_client ->
  import h1, p, a, br, ul, tt, li from require 'lib.html'

  moon = '\xe2\x98\xbd'
  demos =
    'twisted': 'canvas animation',
    'todo': 'Todo demo of a simple reactive UI framework',
    'realities': 'draft of a paper on virtual and other realities',
    'center-of-mass': 'aligning characters by their centers of mass',
    'test-component': 'Test suite for the UI framework',
    'play-tags': 'Playground for Functional Tags',

  back_button = ->
    append p a { '< back', href: '/' }

  if window.location.search and #window.location.search > 1
    name = window.location.search\sub 2
    if demos[name]
      back_button!
      filename = name\gsub '-', '_'
      require "app.#{filename}"
    else
      append h1 'are you lost?'
      append p a { '(go home)', href: '/' }
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
      li (a name, href: "/?#{name}"), ': ', desc

  append p {
    "made with #{moon} by "
    a { 's-ol', href: 'https://twitter.com/S0lll0s' }
  }
