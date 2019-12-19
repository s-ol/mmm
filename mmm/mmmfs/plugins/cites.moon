import div, span, sup, a, i, b from require 'mmm.dom'

parse_bibtex = (src) ->
  type, key, kv = src\match '@(%w+){(.-),(.*)}'
  with info = { _type: type, _key: key }
    for key, val in kv\gmatch '([a-z]-)%s*=%s*{(.-)}'
      info[key] = val

title = (info) ->
  assert info.title, "cite doesn't have title"
  inner = i info.title
  if info.url
    a inner, href: info.url, style: display: 'inline'
  else
    b inner

format_full = (info) ->
  tt = title info
  dot, com = if info.title\match '[.?!]$' then '', '' else '.', ','
  switch info._type
    when 'book', 'article'
      span "#{info.author} (#{info.year}), ", tt, "#{dot} #{info.publisher}"
    when 'web'
      -- note = if info.note then ", #{info.note}" else ''
      visited = if info.visited then " from #{info.visited}" else ""
      span tt, "#{com} #{info.url}#{visited}"
    else
      span "#{info.author} (#{info.year}), ", tt, "#{dot} #{info.publisher}"

{
  converts: {
    {
      inp: 'URL -> cite/acm'
      out: 'URL -> text/bibtex'
      cost: 0.5
      transform: (url) =>
        id = assert (url\match '//dl%.acm%.org/citation%.cfm%?id=(%d+)'), "couldn't parse cite/acm URL: '#{url}'"
        uri = "https://dl.acm.org/downformats.cfm?id=#{id}&parent_id=&expformat=bibtex"
        if MODE == 'CLIENT'
          "https://cors-anywhere.herokuapp.com/#{uri}"
        else
          uri
    }
    {
      inp: 'text/bibtex'
      out: 'mmm/dom'
      cost: 1
      transform: (bib) => format_full parse_bibtex bib
    }
    {
      inp: 'text/bibtex'
      out: 'mmm/dom+link'
      cost: 1
      transform: (bib) =>
        info = parse_bibtex bib
        note = format_full info

        key = tostring 1
        id = "sideref-#{key}"

        intext = sup a key, href: "##{id}"

        span intext, div {
            class: 'sidenote'
            style:
              'margin-top': '-1rem'

            div :id, class: 'hook'
            b key, class: 'ref'
            ' '
            note
          }
    }
  }
}
