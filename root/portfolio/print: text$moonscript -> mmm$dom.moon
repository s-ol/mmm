import tohtml, text, elements from require 'mmm.component'
import article, a, b, video, img, h1, h2, div, p, ul, li, br from elements
import embed, link_to from (require 'mmm.mmmfs.util') elements

embed_img = (src) -> (style) -> img :src, :style
embed_vid = (src) -> (style) -> video autoplay: true, loop: true, muted: true, :src, :style

import artistic, game, js, lua, shader, hardware, tool, collab, professional, cs, cpp from setmetatable {}, __index: (t, k) -> k

padded_ul = (tbl) ->
  ul with tbl
    .style = padding: '0 2rem 0.5rem'

education = {
    {
      name: 'FabAcademy / OpenDot'
      desc: 'Digital Fabrication'
      href: 'http://fabacademy.org/'
      extra: '2020, Milan'
      content: padded_ul {
        li text 'parametric 3d design'
        li text 'CAM and CNC machining, lasercutting, 3D printing'
        li text 'electronics design and production'
        li text 'casting and molding'
      }
    }
    {
      name: 'Cologne Game Lab / TH Köln'
      desc: 'BA Digital Games'
      extra: '2015 - 2019, Cologne'
      href: 'https://colognegamelab.de/'
      content: padded_ul {
        li text 'specialization in game programming'
      }
    }
    {
      name: 'Heinrich-Hertz-Gymnasium'
      desc: 'MINT High school'
      extra: '2007 - 2015, Berlin'
      href: 'https://www.hhgym.de/'
      content: padded_ul {
        li text 'advanced courses in computer science and physics'
      }
    }
}

work = {
    {
      name: 'Slow Bros (Harold Halibut)'
      desc: 'Tool & Game Development'
      extra: 'April 2019 - ongoing (consulting)'
      content: padded_ul {
        li text 'lead development of minigames & interactions'
        li text 'tool development'
        li text 'shader programming'
        li text 'porting (various consoles)'
      }
      href: 'http://haroldhalibut.com/'
      media: embed_img 'http://haroldhalibut.com/wp-content/uploads/2016/07/AgoraArcades2.png'
      tags: :cs, :professional, :game
    }
    {
      name: 'ludopium (Vectronom)'
      desc: 'Game Development'
      extra: 'July 2018 - Decemer 2019'
      content: padded_ul {
        li text 'Unity/C# development (gameplay, UI, tools)'
        li {
          text 'backend for storing and sharing UGC across platforms (clojure)'
          ul {
            li text 'integration with Steam and Nintendo services'
          }
        }
        li {
          text 'development of tech for showcase booths'
          ul {
            li text 'realtime speedrunning leaderboard (node, react)'
            li text 'custom RGB LED driver and lettering'
          }
        }
        li text 'porting to Nintendo Switch, Android, iOS, tvOS'
        li text 'HLSL shader palette system'
      }
      href: 'https://vectronom.arte.tv'
      media: embed_vid '/portfolio/vectronom/media:video/webm'
      tags: :cs, :professional, :js, :shader, :game
    }
    {
      name: 'rise technologies'
      desc: 'Full-Stack Development'
      extra: 'April 2016 - April 2019'
      content: padded_ul {
        li text 'front-end development (react, material-ui)'
        li text 'back-end development (node, MongoDB, RabbitMQ)'
        li text 'mobile development (iOS & android)'
        li text 'webRTC conferencing (janus-gateway, C)'
        li {
          text 'dev-ops (Azure, Amazon AWS)'
          ul {
            li text 'designed and implemented a custom CI system and deployment'
            li text 'supervised migration from MS Azure to Amazon AWS'
          }
        }
      }
      href: 'https://rise.tech'
      media: embed_img '/portfolio/rise/media:image/png'
      tags: :professional, :js, :tool
    }
  }

project_row = (list, tag, exclude) ->
  with ul style: 'padding-left': '1rem'
    for pp in *list 
      continue if tag and not pp.tags[tag]
      continue if not tag and exclude and pp.tags[exclude]

      \append li {
        style:
          display: 'flex'
          margin: '1rem 0'
          'padding-bottom': '0.5em'
          overflow: 'hidden'
          'font-size': '0.9em'
          'break-inside': 'avoid-page'

        div {
          style:
            flex: '1 0 25em'

          a {
            style:
              display: 'block'
              position: 'relative'
              color: 'var(--gray-dark)'
              background: 'var(--gray-bright)'
              'margin-bottom': '0.5rem'
              filter: 'none'

            href: pp.href

            h2 pp.desc, style:
              padding: '0.4rem 1rem'
          }

          if pp.extra
            div pp.extra, style:
              color: 'var(--gray-dark)'
              padding: '0.2em 1rem'
        }

        div {
          style:
            width: '45em'
            'margin-left': 'auto'

          h2 {
            style:
              padding: '0.4rem 1rem'
              background: 'var(--gray-bright)'
              'margin-bottom': '0.5rem'

            text pp.name
          }

          if pp.content then pp.content
          else if pp.entries then padded_ul for line in *pp.entries do li text line
        }
      }

tohtml with article!
  \append p "I am a ", (b 'developer and creative technologist'), " currently based in Milan.
    I have experience working with a wide variety of technologies (both soft- and hardware)
    and enjoy learning new skills with every project.", style: 'margin-top': 0

  \append div (b 'spoken languages:'), " native german, excellent english, good italian"

  \append p "For a detailled overview of my skillset and personal projects, please take a look at
    my portfolio at ", (a 's-ol.nu/portfolio', href: 'https://s-ol.nu/portfolio'), '.'

  \append h2 "professional work experience", style: 'margin-top': '1em'
  \append project_row work, professional

  \append h2 "education", style: 'margin-top': '1em'
  \append project_row education
