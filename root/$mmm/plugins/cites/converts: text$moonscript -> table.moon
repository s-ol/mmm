import div, span, sup, a, i, b from require 'mmm.dom'

parse_bibtex = (src) ->
  type, key, kv = src\match '@(%w+){(.-),(.*)}'
  with info = { _type: type, _key: key }
    for key, val in kv\gmatch '([a-z]-)%s*=%s*(%b{})'
     val\sub 2, -2
     info[key] = val\gsub '[{}]', ''
    for key, val in kv\gmatch '([a-z]-)%s*=%s*(%d+)'
      info[key] = val

title = () =>
  assert @title, "cite doesn't have title"
  inner = i @title
  if @url
    a inner, href: @url, style: display: 'inline'
  else
    b inner

format_full = () =>
  tt = title @
  dot, com = if @title\match '[.?!]$' then '', '' else '.', ','

  @author or= 'N. N.'
  
  switch @_type
    when 'book', 'article'
      span with setmetatable {}, __index: table
        \insert "#{@author} (#{@year}), "
        \insert tt
        if @journal
          \insert "#{dot} "
          \insert i @journal
          \insert ", volume #{@volume}" if @volume
        else if @series
          \insert "#{dot} "
          \insert i @series
          \insert ", No. #{@number}" if @number
        \insert ", pages #{@pages}" if @pages
        \insert "#{dot} #{@publisher}" if @publisher
        if @doi
          \insert "#{dot} "
          \insert a "doi:#{@doi}", href: "https://doi.org/#{@doi}"
    when 'web', 'online'
      span with setmetatable {}, __index: table
        \insert "#{@author}"
        \insert " (#{@year})" if @year
        \insert ", "
        \insert tt
        \insert "#{com} #{@url}"
        \insert " from #{@visited}" if @visited
    else
      span with setmetatable {}, __index: table
        \insert "#{@author} (#{@year}), "
        \insert tt
        \insert "#{dot} #{@publisher}" if @publisher
      span tbl
{
  {
    inp: 'cite/doi'
    out: 'URL -> text/bibtex'
    cost: 0.1
    transform: (doi) =>
      doi = doi\match '(10%.%d%d%d%d%d?%d?%d?%d?%d?/[%d%w%.%-_:;%(%)]+)'
      "http://api.crossref.org/works/#{doi}/transform/application/x-bibtex"
  }
  {
    inp: 'text/bibtex'
    out: 'mmm/dom'
    cost: 1
    transform: (bib) => format_full parse_bibtex bib
  }
}
