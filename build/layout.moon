import header, footer, div, h1, span, b, a, img from require 'mmm.dom'

pick = (...) ->
  num = select '#', ...
  i = math.ceil math.random! * num
  select i, ...


iconlink = (href, src, alt, style) -> a {
  class: 'iconlink',
  :href,
  target: '_blank',
  img :src, :alt, :style
}

{
  header: header {
    h1 {
      span '\xe2\x98\x89', class: 'sun'
      b!
      span 'mmm', class: 'bold'
      '.s-ol.nu'
    }
    span "fun stuff with code and wires"
  --        pick 'fun', 'cool', 'weird', 'interesting', 'new'
  --        pick 'stuff', 'things', 'projects', 'experiments', 'news'
  --        "with"
  --        pick 'mostly code', 'code and wires', 'silicon', 'electronics'
  }
  footer: footer {
    span {
      'made with \xe2\x98\xbd by '
      a 's-ol', href: 'https://twitter.com/S0lll0s'
      ", #{os.date '%Y'}"
    }
    div {
      class: 'icons',
      iconlink 'https://github.com/s-ol/mmm', 'https://cdn.jsdelivr.net/npm/simple-icons@latest/icons/github.svg',
      iconlink 'https://twitter.com/S0lll0s', 'https://cdn.jsdelivr.net/npm/simple-icons@latest/icons/twitter.svg',
      iconlink 'https://webring.xxiivv.com/#random', 'https://webring.xxiivv.com/icon.black.svg', 'webring',
        { height: '1.3em', 'margin-left': '.3em', 'margin-top': '-0.12em' }
    }
  }
}
