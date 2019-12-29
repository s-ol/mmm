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

  -- @author = deandify @author if @author
  -- @editor = deandify @editor if @editor
  
  switch @_type
    when 'book', 'article'
      span with setmetatable {}, __index: table
        \insert "#{@author} (#{@year}), "
        \insert tt
        if @journal
          \insert "#{dot} "
          \insert i @journal
          \insert ", volume #{@volume}" if @volume
        \insert ", pages #{@pages}" if @pages
        \insert "#{dot} #{@publisher}" if @publisher
    when 'web', 'online'
      span with setmetatable {}, __index: table
        \insert "#{@author} (#{@year}), " if @author and @year
        \insert tt
        \insert " (#{@year})" if @year and not @author
        \insert "#{com} #{@url}"
        \insert " from #{@visited}" if @visited
    else
      span with setmetatable {}, __index: table
        \insert "#{@author} (#{@year}), "
        \insert tt
        \insert "#{dot} #{@publisher}" if @publisher
      span tbl
{
  converts: {
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
}
