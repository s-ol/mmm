-- relative imports
_G.relative = do
  _require = require

  (base, sub) ->
    sub = sub or 0

    for i=1, sub
      base = base\match '^(.*)%.%w+$'

    (name, x) ->
      if name == '.'
        name = base
      else if '.' == name\sub 1, 1
        name = base .. name

      _require name

sort2 = (a, b) ->
  {ax, ay}, {bx, by} = a, b
  "#{ax}//#{ay}" < "#{bx}//#{by}"

toseq = (iter) ->
  with v = [x for x in iter]
    table.sort v

toseq2 = (iter) ->
  with v = [{x, y} for x, y in iter]
    table.sort v, sort2

{
  :toseq
  :toseq2
}
