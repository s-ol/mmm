import div, a, i, b from require 'mmm.dom'

title = (info) ->
  assert info.title, "cite doesn't have title"
  inner = i info.title
  if info.url
    a inner, href: info.url
  else
    b inner

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
      transform: (src) =>
        type, key, kv = src\match '@(%w+){(.-),(.*)}'
        info = {}
        for key, val in kv\gmatch '([a-z]-)%s*=%s*{(.-)}'
          info[key] = val

        tt = title info
        dot, com = if info.title\match '[.?!]$' then '', '' else '.', ','
        switch type
          when 'book', 'article'
            div "#{info.author} (#{info.year}), ", tt, "#{dot} #{info.publisher}"
          when 'web'
            -- note = if info.note then ", #{info.note}" else ''
            div tt, "#{com} #{info.url} from #{info.visited}"
          else
            div "#{info.author} (#{info.year}), ", tt, "#{dot} #{info.publisher}"
    }
  }
}
