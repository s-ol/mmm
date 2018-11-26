(elements) ->
  import a from elements

  find_fileder = (fileder, origin) ->
    if 'string' == type fileder
      assert origin, "cannot resolve path '#{fileder}' without origin!"
      assert (origin\walk fileder), "couldn't resolve path '#{fileder}' from #{origin}"
    else
      assert fileder, "no fileder passed."

  link_to = (fileder, name, origin) ->
    fileder = find_fileder fileder, origin

    name or= fileder\get 'title: mmm/dom'
    name or= fileder\gett 'name: alpha'

    if href = fileder\get 'link: URL.*'
      a name, :href, target: '_blank'
    else
      a name, {
        href: fileder.path
        onclick: (e) =>
          e\preventDefault!
          BROWSER\navigate fileder.path
      }

  embed = (fileder, name='', origin) ->
    fileder = find_fileder fileder, origin

    node = fileder\gett name, 'mmm/dom'
    link_to fileder, node

  {
    :find_fileder
    :link_to
    :embed
  }
