encode = (obj) ->
  switch type obj
    when 'string'
      string.format '%q', obj
    when 'table'
      if obj[1] or not next obj
        "[#{table.concat [encode c for c in *obj], ','}]"
      else
        "{#{table.concat ["#{encode k}: #{encode v}" for k,v in pairs obj], ', '}}"
    when 'number'
      tostring obj
    when 'boolean'
      tostring obj
    when 'nil'
      'null'
    else
      error "unknown type '#{type obj}'"

decode = if MODE == 'CLIENT'
  import Array, Object, JSON from js.global

  fix = (val) ->
    switch type val
      when 'userdata'
        if Array\isArray val
          [fix x for x in js.of val]
        else
          {(fix e[0]), (fix e[1]) for e in js.of Object\entries(val)}
      else
        val

  encode
  decode = (str) -> fix JSON\parse str
else if cjson = require 'cjson'
  cjson.decode
else
  warn 'only partial JSON support, please install cjson'


{
  converts: {
    {
      inp: 'table',
      out: 'text/json',
      cost: 2
      transform: (val) => encode val
    }
    if decode
      {
        inp: 'text/json'
        out: 'table'
        cost: 1
        transform: (val) => decode val
      }
  }
}
