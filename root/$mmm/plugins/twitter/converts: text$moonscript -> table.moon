import div, blockquote, a from require 'mmm.dom'
import iframe from require 'mmm.dom'

{
  {
    inp: 'URL -> twitter/tweet'
    out: 'mmm/dom'
    cost: -4
    transform: (href) =>
      user, id = assert (href\match 'twitter.com/([^/]-)/status/(%d*)'), "couldn't parse twitter/tweet URL: '#{href}'"

      iframe {
        width: 550
        height: 560
        border: 0
        frameBorder: 0
        allowfullscreen: true
        src: "//twitframe.com/show?url=https%3A%2F%2Ftwitter.com%2F#{user}%2F#{id}"
      }
  }
}
