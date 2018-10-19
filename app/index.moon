import h1, p, a, br, ul, tt, li from require 'lib.html'

moon = '\xe2\x98\xbd'
demos =
  'twisted': 'canvas animation',
  'todo': 'Todo demo of a simple reactive UI framework',
  'realities': 'draft of a paper on virtual and other realities',
  'center_of_mass': 'aligning characters by their centers of mass',
  'test_component': 'Test suite for the UI framework',
  'tags': 'Playground for Functional Tags',

on_client ->
  redirs =
    'center-of-mass': 'center_of_mass',
    'test-component': 'test_component',
    'play-tags': 'tags',

  { :location } = window
  if location.search and #location.search > 1
    name = location.search\sub 2
    location.href = "#{redirs[name] or name}.html"

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
