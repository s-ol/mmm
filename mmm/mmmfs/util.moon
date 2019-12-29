refs = require 'mmm.refs'

merge = (orig={}, extra) ->
  with attr = {k,v for k,v in pairs orig}
    for k,v in pairs extra
      attr[k] = v

tourl = (path) ->
  if STATIC
    path .. '/'
  else
    path .. '/'

(elements) ->
  import a, div, span, sup, b, pre from elements

  find_fileder = (fileder, origin) ->  
    if 'string' == type fileder
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

  link_to = (fileder, name, origin, attr) ->
    fileder = find_fileder fileder, origin

    name or= fileder\get 'title: mmm/dom'
    name or= fileder\gett 'name: alpha'

    if href = fileder\get 'link: URL.*'
      a name, merge attr, :href, target: '_blank'
    else
      a name, merge attr, {
        href: tourl fileder.path
        onclick: if MODE == 'CLIENT' then (e) =>
          e\preventDefault!
          BROWSER\navigate fileder.path
      }

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
          node
          if opts.desc
            div opts.desc, class: 'description'
        }

        if opts.nolink
          node
        else
          link_to fileder, node, nil, opts.attr

      when 'sidenote'
        key = opts.desc or tostring refs\get!
        id = "sideref-#{key}"

        intext = sup a key, href: "##{id}"

        span intext, div {
            class: 'sidenote'
            style:
              'margin-top': '-1rem'

            div :id, class: 'hook'
            b key, class: 'ref'
            ' '
            node
          }
      else
        error "unknown embed 'wrap': '#{opts.wrap}'"

  {
    :find_fileder
    :link_to
    :navigate_to
    :embed
  }
