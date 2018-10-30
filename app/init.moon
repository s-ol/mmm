require = relative ...

union = (...) -> with res = {}
  c = 1
  for i = 1, select '#', ...
    tbl = select i, ...
    for val in *tbl
      res[c] = val
      c += 1

map = (f, list) -> [f val for val in *list]

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

articles = {
  {
    name: 'realities'
    desc: 'exploring the nesting relationships of virtual and other realities'
  },
  {
    name: 'mmmfs'
    desc: 'a file and operating system to live in (wip)'
  },
}

animations = {
  {
    name: 'twisted'
    desc: 'pseudo 3d animation'
  },
  {
    name: 'koch'
    desc: "lil' fractal thing"
  },
}

experiments = {
  {
    name: 'center_of_mass'
    desc: 'aligning characters by their centers of mass'
  },
  {
    name: 'tags'
    desc: 'organizing files with Functional Tags'
  },
}

meta = {
  {
    name: 'todo'
    desc: 'Todo MVC with the mmm UI framework'
  },
  {
    name: 'test_component'
    desc: 'test suite for the mmm reactive UI framework'
  },
}

content = {
  { 'articles', articles }
  { 'animations', animations }
  { 'experiments', experiments }
  { 'meta', meta }
}

index = {
  name: 'index'
  route: ''
  dest: 'index.html'
  render: =>
    import h1, h3, div, b, p, a, br, ul, tt, li, img from require 'lib.dom'
    import opairs from require 'lib.ordered'

    moon = '\xe2\x98\xbd'

    -- redirects for old-style URIs
    on_client patch_redirs

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

    for { category, routes } in *content
      append h3 category, style: { 'margin-bottom': '-.5em' }
      append ul for { :name, :desc, :route } in *routes
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

routes = map destify, union articles, animations, experiments, meta, { index }
{
  :routes,
  indexed: { r.name, r for r in *routes }
  render: (name) -> require ".#{name}"
}
