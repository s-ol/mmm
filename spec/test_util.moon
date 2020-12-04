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
