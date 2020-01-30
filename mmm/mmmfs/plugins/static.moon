extensions = {
  'image/jpeg': 'jpg'
  'image/png': 'png'

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
        escaped_from = @from\gsub '/', '$'
        if ext = extensions[@from]
          escaped_from ..= ".#{ext}"

        with url = "#{fileder.path}/#{key.name}:#{escaped_from}"
          print "  rendering asset #{url}"
          STATIC.spit url, val
    }
  }
}
