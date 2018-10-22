require = relative ...
import opairs from require 'lib.ordered'

merge = (tables) ->
  first = table.remove tables, 1
  for tbl in *tables
    for k,v in pairs tbl
      first[k] = v
  first

experiments =
  twisted: {
    desc: 'canvas animation'
    render: -> require '.twisted'
  },
  todo: {
    desc: 'Todo demo of a simple reactive UI framework'
    render: -> require '.todo'
  },
  realities: {
    desc: 'draft of a paper on virtual and other realities'
    render: -> require '.realities'
  },
  center_of_mass: {
    desc: 'aligning characters by their centers of mass'
    render: -> require '.center_of_mass'
  },
  test_component: {
    desc: 'Test suite for the UI framework'
    render: -> require '.test_component'
  },
  tags: {
    desc: 'Playground for Functional Tags'
    render: -> require '.tags'
  },
  quasihilbert: {
    desc: "lil' fractal thing",
    render: -> require '.quasihilbert'
  },

destify = (name, route) ->
  name, with route
    .route = name
    .dest = "#{name}/index.html"

routes = { destify k,v for k,v in pairs experiments }

patch_redirs = ->
  redirs =
    'center-of-mass': 'center_of_mass',
    'test-component': 'test_component',
    'play-tags': 'tags',

  { :location } = window
  if location.search and #location.search > 1
    name = location.search\sub 2
    location.href = redirs[name] or name

routes.index = {
  route: ''
  dest: 'index.html'
  render: =>
    import h1, p, a, br, ul, tt, li from require 'lib.html'
    import opairs from require 'lib.ordered'

    moon = '\xe2\x98\xbd'

    -- redirects for old-style URIs
    on_client patch_redirs

    -- menu
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
    append ul for name, { :desc, :route } in opairs experiments
      li (a name, href: route), ': ', desc

    append p {
      "made with #{moon} by "
      a { 's-ol', href: 'https://twitter.com/S0lll0s' }
    }
}

{
  :routes,
  render: (name) -> require ".#{name}"
}
