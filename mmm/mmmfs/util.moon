merge = (orig={}, extra) ->
  with attr = {k,v for k,v in pairs orig}
    for k,v in pairs extra
      attr[k] = v

(elements) ->
  import a, div, span, pre from elements

  find_fileder = (fileder, origin) ->
    if 'string' == type fileder
      assert origin, "cannot resolve path '#{fileder}' without origin!"
      assert (origin\walk fileder), "couldn't resolve path '#{fileder}' from #{origin}"
    else
      assert fileder, "no fileder passed."

  navigate_to = (path, name, opts={}) ->
    opts.href = path
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
        href: fileder.path
        onclick: if MODE == 'CLIENT' then (e) =>
          e\preventDefault!
          BROWSER\navigate fileder.path
      }

  embed = (fileder, name='', origin, opts={}) ->
    fileder = find_fileder fileder, origin

    -- node = fileder\gett name, 'mmm/dom'
    ok, node = pcall fileder.gett, fileder, name, 'mmm/dom'

    if not ok
      return span "couldn't embed #{fileder} #{name}",
          (pre node),
          class: 'embed'
          style: {
            background: 'var(--gray-fail)',
            padding: '1em',
          }

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
