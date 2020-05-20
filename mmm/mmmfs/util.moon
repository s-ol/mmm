refs = require 'mmm.refs'

merge = (orig={}, extra={}) ->
  with attr = {k,v for k,v in pairs orig}
    for k,v in pairs extra
      attr[k] = v

tourl = (path, _view) ->
  path ..= '/'
  if STATIC and STATIC.root
    path = STATIC.root .. path
  if _view
    path ..= _view
  path

(elements) ->
  import a, div, span, sup, b, pre from elements

  find_fileder = (fileder, origin) ->  
    if 'string' == type fileder
      if fileder == ''
        assert origin, "cannot resolve empty path without origin!"
        return origin

      if '/' ~= fileder\sub 1, 1
        assert origin, "cannot resolve relative path '#{fileder}' without origin!"
        fileder = "#{origin.path}/#{fileder}"

      while fileder\match '/([^/]-)/%.%./'
        fileder = fileder\gsub '/([^/]-)/%.%./', '/'

      if origin.path == fileder\sub 1, #origin.path   
        assert (origin\walk fileder), "couldn't resolve path '#{fileder}' from #{origin}"
      else
        assert BROWSER and BROWSER.root, "cannot resolve absolute path '#{fileder}' without BROWSER and root set!"
        assert (BROWSER.root\walk fileder), "couldn't resolve path '#{fileder}'"
    else
      assert fileder, "no fileder passed."

  navigate_to = (path, name, opts={}) ->
    opts.href = tourl path
    opts.onclick = if MODE == 'CLIENT' then (e) =>
      e\preventDefault!
      BROWSER\navigate path
    a name, opts

  link_to = (fileder, name, origin, attr, _view) ->
    fileder = find_fileder fileder, origin

    name or= fileder\get 'title: mmm/dom'
    name or= fileder\gett 'name: alpha'

    if href = fileder\get 'link: URL*'
      a name, merge attr, :href, target: '_blank'
    else
      a name, merge attr, {
        href: tourl fileder.path, _view
        onclick: if MODE == 'CLIENT' then (e) =>
          e\preventDefault!
          BROWSER\navigate fileder.path
      }

  interactive_link = (text, view=':text/html+interactive') ->
    assert MODE == 'SERVER'
    path = BROWSER.path
    path = table.concat path, '/' if 'table' == type BROWSER.path
    a text, href: tourl path, view

  embed = (fileder, name='', origin, opts={}) ->
    if opts.raw
      warn "deprecated option 'raw' set on embed"
      assert not opts.wrap, "raw and wrap cannot both be set on embed"
      opts.wrap = 'raw'
    opts.wrap or= 'well'
    
    fileder = find_fileder fileder, origin

    -- node = fileder\gett name, 'mmm/dom'
    ok, node = pcall fileder.gett, fileder, name, 'mmm/dom'

    if not ok
      warn "couldn't embed #{fileder} #{name}: #{node}"
      return span {
        class: 'embed'
        style:
          background: 'var(--gray-fail)'
          padding: '1em'

        "couldn't embed #{fileder} #{name}"
        (pre node)
      }

    klass = 'embed'
    klass ..= ' desc' if opts.desc
    klass ..= ' inline' if opts.inline

    switch opts.wrap
      when 'raw'
        node

      when 'well'
        node = span {
          class: klass
          style: opts.style
          node
          if opts.desc
            div opts.desc, class: 'description'
        }

        if opts.nolink
          node
        else
          link_to fileder, node, nil, opts.attr

      when 'sidenote'
        key = tostring refs\get!
        id = "sideref-#{key}"

        intext = sup a key, href: "##{id}"

        span intext, div {
            class: 'sidenote'
            style: opts.style or 'margin-top: -1.25rem;'

            div :id, class: 'hook'
            b key, class: 'ref'
            ' '
            opts.desc or ''
            node
          }

      when 'marginnote'
        div {
          class: 'sidenote'
          style: opts.style

          opts.desc or ''
          node
        }

      else
        error "unknown embed 'wrap': '#{opts.wrap}'"

  {
    :find_fileder
    :link_to
    :interactive_link
    :navigate_to
    :embed
  }
