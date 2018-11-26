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

So here are all my current themes:

<mmm-embed path="cavetree"></mmm-embed>
<mmm-embed path="akira"></mmm-embed>
<mmm-embed path="sidewalk"></mmm-embed>
<mmm-embed path="hotline"></mmm-embed>
<mmm-embed path="polar"></mmm-embed>
<mmm-embed path="polysun"></mmm-embed>
<mmm-embed path="psych"></mmm-embed>
<mmm-embed path="trippy"></mmm-embed>
<mmm-embed path="twostripe"></mmm-embed>
<mmm-embed path="bwcube"></mmm-embed>

The wallpaper for the last one is intended to be tiled, not stretched, but that currently requries a manual change in my i3 config:
<mmm-embed path="dark"></mmm-embed>

I am thinking about implementing this as a Themer feature, but it would require it's own *presentation* plugin type,
so everyone can choose their own commands, bars, and waiting time.

You can find more information about [Themer on the github page][themer], along with all my [config files][dotfiles].

[themer]:     https://github.com/s-ol/themer
[dotfiles]:   https://github.com/s-ol/dotfiles
