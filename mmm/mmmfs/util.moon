(elements) ->
  import a from elements

  link_to = (fileder, name) ->
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

  {
    :link_to
  }
