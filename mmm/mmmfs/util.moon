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
  import a, div, span, pre from elements

  find_fileder = (fileder, origin) ->  
    if 'string' == type fileder
      if '/' ~= fileder\sub 1, 1
        assert origin, "cannot resolve relative path '#{fileder}' without origin!"
        fileder = "#{origin.path}/#{fileder}"

      fileder = fileder\gsub '/([^/]-)/%.%./', '/'
      if origin.path == fileder\sub 1, #origin.path   
        assert (origin\walk fileder), "couldn't resolve path '#{fileder}' from #{origin}"
      else
        assert BROWSER and BROWSER.root, "cannot resolve absolute path '#{fileder}' without BROWSER and root set!"
        assert (BROWSER.root\walk fileder), "couldn't resolve path '#{fileder}'"

    -- if 'string' == type fileder
    --   if '/' == fileder\sub 1, 1
    --     fileder = fileder\gsub '/([^/]-)/%.%./', '/'
    --     assert BROWSER and BROWSER.root, "cannot resolve absolute path '#{fileder}' without BROWSER and root set!"
    --     assert (BROWSER.root\walk fileder), "couldn't resolve path '#{fileder}'"
    --   else
    --     assert origin, "cannot resolve relative path '#{fileder}' without origin!"
    --     fileder = "#{origin.path}/#{fileder}"
    --     fileder = fileder\gsub '/([^/]-)/%.%./', '/'
    --     if origin.path == fileder\sub 1, #origin.path
    --       assert (origin\walk fileder), "couldn't resolve path '#{fileder}' from #{origin}"
    --     else
    --       assert BROWSER and BROWSER.root, "cannot resolve absolute path '#{fileder}' without BROWSER and root set!"
    --       assert (BROWSER.root\walk fileder), "couldn't resolve path '#{fileder}'"

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

    return node if opts.raw

    klass = 'embed'
    klass ..= ' desc' if opts.desc
    klass ..= ' inline' if opts.inline

    node = span {
      class: klass
      node
      if opts.desc
        div opts.desc, class: 'description'
    }

    return node if opts.nolink
    link_to fileder, node, nil, opts.attr

  {
    :find_fileder
    :link_to
    :navigate_to
    :embed
  }
