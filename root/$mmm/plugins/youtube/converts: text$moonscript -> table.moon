import iframe from require 'mmm.dom'

{
  {
    inp: 'URL -> youtube/video'
    out: 'mmm/dom'
    cost: -4
    transform: (link) =>
      id = link\match 'youtu%.be/([^/]+)'
      id or= link\match 'youtube.com/watch.*[?&]v=([^&]+)'
      id or= link\match 'youtube.com/[ev]/([^/]+)'
      id or= link\match 'youtube.com/embed/([^/]+)'

      assert id, "couldn't parse youtube URL: '#{link}'"

      iframe {
        width: 560
        height: 315
        border: 0
        frameborder: 0
        allowfullscreen: true
        src: "//www.youtube.com/embed/#{id}"
      }
  }
}
