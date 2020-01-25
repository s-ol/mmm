import ReactiveVar, tohtml, text, elements from require 'mmm.component'
import article, a, video, img, h1, div, p, ul, li, br from elements
import embed, link_to from (require 'mmm.mmmfs.util') elements

embed_img = (src) -> (style) -> img :src, :style
embed_vid = (src) -> (style) -> video autoplay: true, loop: true, muted: true, :src, :style

import artistic, game, js, lua, shader, hardware, tool, collab, professional, cs, cpp from setmetatable {}, __index: (t, k) -> k

padded_ul = (tbl) ->
  ul with tbl
    .style = padding: '0 2rem 0.5rem'

projects = {
    {
      name: 'Vectronom / Ludopium'
      desc: 'Technical Artist, Game Development'
      extra: 'July 2018 - Decemer 2019'
      content: padded_ul {
        li text 'Unity/C# development (gameplay, UI, tools)'
        li {
          text 'backend for storing and sharing UGC across platforms'
          ul {
            li text 'SQL-backed storage of user-created levels'
            li text 'implemented in clojure with clojure-ring'
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
      name: 'Harold Halibut / Slow Bros'
      desc: 'Tool & Game Development'
      extra: 'April - Decemer 2019 (consulting)'
      content: padded_ul {
        li {
          text 'Unity/C# development'
          ul {
            li text 'developed multiple mini-games and interactions'
          }
        }
        li text 'tool development'
        li text 'shader programming'
        li text 'porting (various consoles)'
      }
      href: 'http://haroldhalibut.com/'
      media: embed_img 'http://haroldhalibut.com/wp-content/uploads/2016/07/AgoraArcades2.png'
      tags: :cs, :professional, :game
    }
    {
      name: 'rise technologies'
      desc: 'Full-Stack Development, Web & App'
      extra: 'April 2016 - April 2019'
      content: padded_ul {
        li text 'front-end development (react, material-ui)'
        li {
          text 'back-end development',
          ul {
            li text 'main application (meteor.js, node, MongoDB)'
            li text 'microservice architecture (node, RabbitMQ)'
            li text 'notification handling & delivery (APN, FCM)'
          }
        }
        li text 'mobile development'
        li {
          text 'webRTC conferencing (janus-gateway)'
          ul {
            li text 'contributed C patches reinforcing the communication security for our needs'
            li text 'implemented client-side logic'
            li text 'implemented gateway orchestration'
          }
        }
        li {
          text 'dev-ops'
          ul {
            li text 'designed and implemented a custom CI system'
            li text 'designed deployment infrastructure on MS Azure (docker, docker-compose)'
            li text 'supervised migration from MS Azure to Amazon AWS'
          }
        }
      }
      href: 'https://rise.tech'
      media: embed_img '/portfolio/rise/media:image/png'
      tags: :professional, :js, :tool
    }
    {
      name: 'ForChange Reserach Fund'
      desc: 'Game Design and Development'
      extra: 'March - June 2017 (consulting)'
      content: padded_ul {
        li {
          text "designed 'Lorem Ipsum' together with two research scientists"
          ul {
            li text 'design goal was to communicate their research findings'
            li text 'created a paper prototype'
            li text 'designed a 4-player social game about truth and perspectives'
          }
        }
        li {
          text 'developed the game as a web application'
          ul {
            li text 'front-end using react'
            li text 'back-end hosts game sessions via WebSockets'
            li text 'joining games via link or QR-code scanning (in-app)'
            li text 'gameplay implemented in immutable/functional-style'
          }
        }
      }
      href: 'https://loremipsum.s-ol.nu/'
      media: embed_img '/portfolio/lorem_ipsum/media:image/jpeg'
      tags: :professional, :js, :collab, :game
    }
    {
      name: 'btrktrl'
      desc: 'a custom MIDI/OSC control surface'
      entries: {
        'encoders with capacitive touch and RGB feedback'
        'custom PCBs based on iCE40 FPGAs'
        'motherboard with Arduino MCU'
        'communication via OSC/USB'
        'individually programmable daughterboards'
      }
      href: '/projects/btrktrl/'
      media: embed_img '/projects/btrktrl/pcb_glamour_top/:image/jpeg'
      tags: :hardware, :tool, :cpp
    }
    {
      name: 'VJmidiKit'
      desc: 'a tool for MIDI-reactive visuals'
      entries: {
        'GLSL shader livecoding'
        'block-based language for MIDI-music reactivity'
        'implemented in openFrameworks/C++'
      }
      href: '/projects/VJmidiKit/'
      media: embed_vid '/portfolio/VJmidiKit/media:video/mp4'
      tags: :tool, :cpp, :shader
    }
    {
      name: 'IYNX'
      desc: 'a narrative, tangible, physical puzzle incorporating digital elements'
      entries: {
        'powered by a raspberry pi 3 and two arduino nanos'
        'touch-panel UI and control software with node, electron and react'
        'interfaces with analog potentiometers, keypad matrix, switches'
      }
      href: '/games/IYNX/'
      media: embed_img '/games/IYNX/pictures/ui_menu/:image/jpeg'
      tags: :collab, :game, :js, :hardware
    }
    {
      name: 'Plonat Atek'
      desc: 'a sound-only breakout game, displayable on an oscilloscope'
      entries: {
        'uses stereo sound to draw visuals on an oscilloscope'
        'programmed in PureData'
        'runs on a Raspberry Pi Zero in a custom case with hardware controls'
        "1st place in Innovation, LudumDare 38 Compo"
      }
      href: '/games/plonat_atek/'
      media: embed_img '/games/plonat_atek/pictures/amaze/:image/jpeg'
      tags: :artistic, :game, :hardware
    }
    {
      name: 'tre telefoni'
      desc: 'experimental interactive installation piece about communication'
      content: padded_ul {
        li text 'realtime voice chat between three participants, in an unusual configuration'
        li {
          text 'web-based prototype'
          ul {
            li text 'realized using webRTC, react'
            li text '3-player matchmaking'
          }
        }
      }
      href: '/projects/iii-telefoni/'
      media: embed_img '/projects/iii-telefoni/heads/:image/jpeg'
      tags: :artistic, :game, :js
    }
    {
      name: '1u matrix mixer'
      desc: 'Embedded Software Development'
      entries: {
        "embedded programming for a Eurorack module"
        "C++, targetting Teensy 3.5"
        "8 encoders with RGB lighting"
        "digtally controls a 8x8 switching matrix and 8 channels of volume modulation"
      }
      media: embed_img '/portfolio/1u-mod/media:image/jpeg'
      tags: :collab, :hardware, :cpp
    }
    {
      name: 'mmm'
      desc: 'experimental file-system/CMS/digital working space'
      content: padded_ul {
        style: padding: '0 2em 1em'
        li text 'powers this website'
        li text 'implemented in Lua/MoonScript'
        li text 'innovative type-coercion system'
        li text 'client/server polymorphic UI framework'
        li text 'built-in server-side rendering and interactive editing support'
      }
      href: '/articles/mmmfs/'
      media: embed_img '/portfolio/mmm/media:image/png'
      tags: :tool, :lua
    }
    {
      name: 'Toy Box Orchestra'
      desc: 'interactive audio-visual performance project'
      entries: {
        "circuit bent childrens' toys"
        "developed a realtime video effect inspired by analog video synthesisers in openframeworks and GLSL"
        "interactive MIDI controls for the effect for performing it on stage"
      }
      href: 'https://chimpanzeebukkaque.bandcamp.com/releases'
      media: embed_img '/portfolio/visualist/media:image/jpeg'
      tags: :collab, :artistic, :cpp, :hardware, :shader
    }
  }

project_row = (tag, exclude) ->
  with ul style: display: 'flex', 'flex-wrap': 'wrap', 'align-items': 'top'
    for pp in *projects
      continue if tag and not pp.tags[tag]
      continue if not tag and exclude and pp.tags[exclude]

      \append li {
        style:
          'border-radius': '6px'
          display: 'flex'
          'flex-direction': 'column'
          width: '22rem'
          margin: '0.5em'
          'padding-bottom': '0.5em'
          background: 'var(--gray-bright)'
          overflow: 'hidden'
          'font-size': '0.9em'

        a {
          style:
            display: 'block'
            position: 'relative'
            color: 'var(--gray-bright)'
            background: 'var(--gray-dark)'
            filter: 'none'

          href: pp.href

          pp.media {
            width: '100%'
            height: '13rem'
            background: 'var(--gray-bright)'
            'box-sizing': 'border-box'
            'object-fit': 'cover'
          }

          h1 pp.name, style:
            padding: '0.2rem 1rem'
        }

        if pp.extra
          div pp.extra, style:
            background: 'var(--gray-darker)'
            color: 'var(--gray-bright)'
            padding: '0.2em 1rem'

        p (text pp.desc), style: 'padding': '0 1rem'
        text ' '
        pp.content or padded_ul for line in *pp.entries
          li text line
      }

tohtml with article!
  filter = ReactiveVar!

  taglink = (label, tag=label) ->
    a label, {
      href: '#'
      onclick: (e) =>
        e\preventDefault!
        filter\transform (old) -> if old == tag then nil else tag
    }

  \append p "I have worked with a wide range of technologies and frameworks. ",
            "Below you can find a breakdown of the ones I am proficient in.", br!,
            "You can click on any of the tags marked in bold to filter the projects below accordingly."

  \append ul {
    li {
      "software programming"
      ul {
        li (taglink "JavaScript", js), ": react, nodejs, electron, meteor"
        li (taglink "C++", cpp), ": openFrameworks, raymarching, SDFs"
        li (taglink "GLSL & HLSL", shader), ": openFrameworks, intermediate openGL"
        li taglink "C# and Unity", cs
        li "Python"
        li "Lua/MoonScript"
      }
    }
    li {
      (taglink hardware), " and embedded programming"
      ul {
        li "PCB Design"
        li text "embedded programming (C++) and interfacing"
        li "FPGA development (Verilog)"
      }
    }
    li {
      "other"
      ul {
        li "Linux"
        li "docker, docker-compose"
        li "HTML, CSS"
      }
    }
  }

  \append with h1 "selected projects", style: 'margin-top': '1em'
    \append a "show all", href: '#', style: { 'font-size': '0.7em', 'margin-left': '1.5em' }, onclick: (e) =>
      e\preventDefault!
      filter\set!
  \append filter\map => project_row @, professional

  \append h1 "professional work", style: 'margin-top': '1em'
  \append p "I have worked for or with the following companies and organisations in the past:"
  \append project_row professional
