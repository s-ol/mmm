extensions = {
  'image/jpeg': 'jpg'
  'image/png': 'png'
  'image/svg+xml': 'svg'

  'video/webm': 'webm'
  'video/mp4': 'mp4'

  'text/javascript': 'js'
  'text/css': 'css'
}

{
  converts: {
    {
      inp: '(.+)',
      out: 'URL -> %1',
      cost: 5
      transform: (val, fileder, key) =>
        escaped_from = @from\gsub '/', '_'
        if ext = extensions[@from]
          escaped_from ..= ".#{ext}"

        prefix = STATIC.root or ''

        prefix .. with url = "#{fileder.path}/#{key.name}:#{escaped_from}"
          print "  rendering asset #{url}"
          STATIC.spit url, val
    }
  }
}
