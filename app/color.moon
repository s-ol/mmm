rgb = (r, g, b) ->
  r, g, b = table.unpack r if 'table' == type r
  "rgb(#{r * 255}, #{g * 255}, #{b * 255})"

rgba = (r, g, b, a) ->
  r, g, b, a = table.unpack r if 'table' == type r
  "rgba(#{r * 255}, #{g * 255}, #{b * 255}, #{a or 1})"

hsl = (h, s, l) ->
  h, s, l = table.unpack h if 'table' == type h
  "hsl(#{h * 360}, #{s * 100}%, #{l * 100}%)"

hsla = (h, s, l, a) ->
  h, s, l, a = table.unpack h if 'table' == type h
  "hsla(#{h * 360}, #{s * 100}%, #{l * 100}%, #{a or 1})"

{
  :rgb, :rgba,
  :hsl, :hsla,
}
