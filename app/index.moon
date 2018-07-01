window = js.global
document = window.document

import h1, p, a, br, ul, tt, li from require './html.moon'

moon = '\xe2\x98\xbd'
demos = 
  'twisted': 'canvas animation',
  'todo': 'Todo demo of a simple reactive UI framework',
  'realities': 'draft of a paper on virtual and other realities',
  'center-of-mass': 'aligning characters by their centers of mass',
  'test-component': 'Test suite for the UI framework',

back_button = ->
  document.body\appendChild p a { '< back', href: '/' }

switch window.location.search
  when '?twisted'
    back_button!
    require './twisted.moon'
  when '?center-of-mass' then
    back_button!
    require './centerofmass.moon'
  when '?todo' then
    back_button!
    require './todo.moon'
  when '?test-component' then
    back_button!
    require './test_component.moon'
  when '?realities' then
    back_button!
    require './realities.moon'
  else
    document.body\appendChild h1 'mmm'
    document.body\appendChild p {
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
    document.body\appendChild p 'current demos:'
    document.body\appendChild ul for name, desc in pairs demos
      li (a name, href: "/?#{name}"), ': ', desc

document.body\appendChild p {
  "made with #{moon} by "
  a { 's-ol', href: 'https://twitter.com/S0lll0s' }
}
