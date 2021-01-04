=>
  scss = ''

  for fileder in *@children
    scss ..= fileder\gett 'text/x-scss'

  scss
