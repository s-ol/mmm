import div, i from require 'mmm.dom'

{
  converts: {
    {
      inp: 'URL -> cite/acm'
      out: 'URL -> text/bibtex'
      cost: 0.5
      transform: (url) =>
        id = assert (url\match '//dl%.acm%.org/citation%.cfm%?id=(%d+)'), "couldn't parse cite/acm URL: '#{url}'"
        "https://cors-anywhere.herokuapp.com/https://dl.acm.org/exportformats.cfm?id=#{id}&expformat=bibtex"
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

        div "#{info.author} (#{info.year}),", (i info.title), ". #{info.publisher}"
    }
  }
}
