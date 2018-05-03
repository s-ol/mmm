window = js.global
document = window.document

import h1, p, a, br, ul, tt, li from require './html.moon'

moon = '\xe2\x98\xbd'
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
    document.body\appendChild ul for name in *{'twisted', 'center-of-mass', 'todo'}
      li a { name, href: "/?#{name}" }

document.body\appendChild p {
  "made with #{moon} by "
  a { 's-ol', href: 'https://twitter.com/S0lll0s' }
}
