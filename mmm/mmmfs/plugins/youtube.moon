import iframe from require 'mmm.dom'

{
  converts: {
    {
      inp: 'URL -> youtube/video'
      out: 'mmm/dom'
      cost: 1
      transform: (link) =>
        id = link\match 'youtu%.be/([^/]+)'
        id or= link\match 'youtube.com/watch.*[?&]v=([^&]+)'
        id or= link\match 'youtube.com/[ev]/([^/]+)'
        id or= link\match 'youtube.com/embed/([^/]+)'

        assert id, "couldn't parse youtube URL: '#{link}'"

        iframe {
          width: 560
          height: 315
          frameborder: 0
          allowfullscreen: true
          frameBorder: 0
          src: "//www.youtube.com/embed/#{id}"
        }
    }
  }
}
