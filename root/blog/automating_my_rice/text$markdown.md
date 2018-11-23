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

[akira]:      {{site.url}}/assets/{{page.imgid}}/akira.png
[bwcube]:     {{site.url}}/assets/{{page.imgid}}/bwcube.png
[cavetree]:   {{site.url}}/assets/{{page.imgid}}/cavetree.png
[dark]:       {{site.url}}/assets/{{page.imgid}}/dark.png
[hotline]:    {{site.url}}/assets/{{page.imgid}}/hotline.png
[laying]:     {{site.url}}/assets/{{page.imgid}}/laying.png
[polar]:      {{site.url}}/assets/{{page.imgid}}/polar.png
[polysun]:    {{site.url}}/assets/{{page.imgid}}/polysun.png
[psych]:      {{site.url}}/assets/{{page.imgid}}/psych.png
[sexy]:       {{site.url}}/assets/{{page.imgid}}/sexy.png
[sidewalk]:   {{site.url}}/assets/{{page.imgid}}/sidewalk.png
[tattooed]:   {{site.url}}/assets/{{page.imgid}}/tattooed.png
[touching]:   {{site.url}}/assets/{{page.imgid}}/touching.png
[trippy]:     {{site.url}}/assets/{{page.imgid}}/trippy.png
[twostripe]:  {{site.url}}/assets/{{page.imgid}}/twostripe.png
