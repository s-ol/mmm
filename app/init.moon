require = relative ...

patch_redirs = ->
  redirs =
    'center-of-mass': 'center_of_mass',
    'test-component': 'test_component',
    'play-tags': 'tags',

  { :location } = window
  if (not location.search\find '=') and #location.search > 1
    name = location.search\sub 2
    location.href = redirs[name] or name

client_goto = ->
  { :location } = window
  if module = location.search\match 'client=([%w_]+)'
    document.body.innerHTML = ''
    require "app.#{module}"

experiments = {
  {
    name: 'twisted'
    desc: 'pseudo 3d animation'
  },
  {
    name: 'koch'
    desc: "lil' fractal thing"
  },
  {
    name: 'realities'
    desc: 'a paper on virtual and other realities'
  },
  {
    name: 'center_of_mass'
    desc: 'aligning characters by their centers of mass'
  },
  {
    name: 'todo'
    desc: 'Todo MVC with the mmm UI framework'
  },
  {
    name: 'test_component'
    desc: 'test suite for the mmm reactive UI framework'
  },
  {
    name: 'tags'
    desc: 'organizing files with Functional Tags'
  },
  {
    name: 'mmmfs'
    desc: 'an operating, file- and living system'
    render: 'client'
  },
}

routes = [x for x in *experiments]

table.insert routes, {
  name: 'index'
  route: ''
  dest: 'index.html'
  render: =>
    import h1, p, a, br, ul, tt, li, img from require 'lib.html'
    import opairs from require 'lib.ordered'

    moon = '\xe2\x98\xbd'

    -- redirects for old-style URIs
    on_client patch_redirs

    -- menu
    append h1 {
      style: {
        position: 'relative',
        'border-bottom': '1px solid #000'
      },
      'mmm',
      a {
        style: {
          position: 'absolute',
          top: '2px',
          right: '0',
        },
        href: 'https://webring.xxiivv.com/#random',
        target: '_blank',
        img src: 'https://webring.xxiivv.com/icon.black.svg', alt: 'webring', style: { height: '1em' }
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
    append p 'current demos:'
    append ul for { :name, :desc, :route } in *experiments
      li (a name, href: route), ': ', desc

    append p {
      "made with #{moon} by "
      a { 's-ol', href: 'https://twitter.com/S0lll0s' }
    }

    on_client client_goto
}

load = (module) -> require "app.#{module}"

destify = (route) -> with route
  .route or= .name
  .dest or= "#{.route}/index.html"

  if .render == 'client'
    .render = -> on_client load, .name
  .render or= -> require '.' .. .name

routes = [ destify route for route in *routes ]
{
  :routes,
  indexed: { r.name, r for r in *routes }
  render: (name) -> require ".#{name}"
}
