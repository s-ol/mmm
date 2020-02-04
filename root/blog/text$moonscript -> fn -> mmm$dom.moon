import div, h3, a, p, ul, li from require 'mmm.dom'
import link_to from (require 'mmm.mmmfs.util') require 'mmm.dom'
import ropairs from require 'mmm.ordered'

=>
  div {
    h3 link_to @
    ul do
      posts = { (p\gett 'date: time/unix'), p for p in *@children }

      posts = for date, post in ropairs posts
        continue if post\get 'hidden: bool'
        li (link_to post, os.date '%F', date), ' - ', post\gett 'title: mmm/dom'

      posts
    p {
      "also check out my weekly posts for the 2020 FabAcademy on my "
      a "fabcloud page", href: 'https://fabacademy.org/2020/labs/opendot/students/sol-bekic/'
      "."
    }
  }
