import div, blockquote, a from require 'mmm.dom'

{
  converts: {
    {
      inp: 'URL -> twitter/tweet'
      out: 'mmm/dom'
      cost: -4
      transform: (href) =>
        id = assert (href\match 'twitter.com/[^/]-/status/(%d*)'), "couldn't parse twitter/tweet URL: '#{href}'"
        if MODE == 'CLIENT'
          with parent = div!
            window.twttr.widgets\createTweet id, parent
        else
          div blockquote {
            class: 'twitter-tweet'
            'data-lang': 'en'
            a '(linked tweet)', :href
          }
    }
  }
  scripts: [[
    <script type="text/javascript" src="//platform.twitter.com/widgets.js" charset="utf-8"></script>
  ]]
}
