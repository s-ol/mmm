I spent the bigger part of today writing a small script that cylces through all my [Themer][themer] themes,
opens a dmenu, prints the theme name with figlet and shows screenfetch before taking a picture.
The script is pretty straightforward:

    #!/usr/bin/bash

    for theme in $(themer list); do
      themer activate $theme
      sleep 20 # wait for bar :/
      dmenu -p "Launch:" $(~/.i3/dmenuconf) < ~/.cache/dmenu_run &
      dmenupid=$!
      clear
      screenfetch
      echo
      toilet --gay $theme
      echo;echo;echo;echo;echo;echo;echo
      themer current

      sleep 1
      scrot $theme.png
      kill $dmenupid
    done

So here are all my current themes (click to view seperately)::

[![cavetree][cavetree]][cavetree]
[![akira][akira]][akira]
[![sidewalk][sidewalk]][sidewalk]
[![hotline][hotline]][hotline]
[![polar][polar]][polar]
[![polysun][polysun]][polysun]
[![psych][psych]][psych]
[![trippy][trippy]][trippy]
[![twostripe][twostripe]][twostripe]
[![bwcube][bwcube]][bwcube]

The wallpaper for the last one is intended to be tiled, not stretched, but that currently requries a manual change in my i3 config:
[![dark][dark]][dark]

I am thinking about implementing this as a Themer feature, but it will require it's own *presentation* plugin type so everyone can choose their own commands, bars, and waiting time,

You can find more information about [Themer on the github page][themer], along with all my [config files][dotfiles].

[themer]:     https://github.com/s-ol/themer
[dotfiles]:   https://github.com/s-ol/dotfiles

[akira]:      {{akira+URL -> image/png}}
[bwcube]:     {{bwcube+URL -> image/png}}
[cavetree]:   {{cavetree+URL -> image/png}}
[dark]:       {{dark+URL -> image/png}}
[hotline]:    {{hotline+URL -> image/png}}
[laying]:     {{laying+URL -> image/png}}
[polar]:      {{polar+URL -> image/png}}
[polysun]:    {{polysun+URL -> image/png}}
[psych]:      {{psych+URL -> image/png}}
[sexy]:       {{sexy+URL -> image/png}}
[sidewalk]:   {{sidewalk+URL -> image/png}}
[tattooed]:   {{tattooed+URL -> image/png}}
[touching]:   {{touching+URL -> image/png}}
[trippy]:     {{trippy+URL -> image/png}}
[twostripe]:  {{twostripe+URL -> image/png}}
