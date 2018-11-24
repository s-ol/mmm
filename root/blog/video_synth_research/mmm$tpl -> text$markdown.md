When we started the *Synths and Stuff* project, we discussed how it would be cool to have video
synthesis to accompany the audio performance. In a modular synth setup, we would be able to patch
audio and control signals into the video phase to make music reactive visuals.

## expensive toys
While I love video synthesis, and my last project before this [was sort of that][plonat-atek], I was
initially a bit worried about the complexity of it.
I had found out about [LZX Industries][lzx] a few months ago, who make amazing modular video synth
gear... that is very expensive. It looks amazing though:

<iframe
  width="560"
  height="315"
  src="https://www.youtube.com/embed/Aba7VD4h6G4"
  allowfullscreen
></iframe>

I think the price is probably justified, as a lot of engineering goes into making this work in the
first place, and it looks very clean, which I would attribute to high quality components.

However, for our project we don't strive to create perfect and clean audio or video.
Glitches and noise are an important part of the analog aesthetic and make the results feel as
organic as they do.

I also found the *3trins-RGB+1c*, which looks like a nifty little thing but is also way out of my
budget.

## visualising another way
Reinforced with these thoughts I started looking for DIY video modules. At least in relation to
audio schematics, there is *very little* content on the internet.
However I did find a few good resources.

There is a 2013 blog with only a few posts, but it does a great job of filtering out relevant
information in [this post summarizing forum gold][vfold].

This led me onto the track of the MC1377 chip, an RGB-to-PAL/NTSC video encoder IC.
At some point I found this video showcasing a video effect device based on it, the *Visualist*:

<iframe
  width="560"
  height="315"
  src="https://www.youtube.com/embed/99j3V9t26pY"
  frameborder="0"
  allowfullscreen
></iframe>

The best thing is that there is [awesome documentation][visualist] (hotlinked from original dropbox,
I have a copy if it goes down) for this thing.
It's not very detailed but the circuit is rather minimal and the color logic easily removed.
The stripped down version that parses an incoming video signal brightness and encodes RGB values you
make from that as the signals scans over the screen is handleable even if not completely understood.

To practice my understanding and work it into my brain, I broke the original schematic out into
logical units with single connections.

My plan is to make the *Visualist* color logic, that pseudo-randomly assigns a color to each
brightness level in a 7-step scale that you can adjust into a small module that can be used,
but also mixed with other effects (perhaps an oscillator and external color input) so that we can
sync to our music control signals.

![][schematic.png]
![][mine.jpg]

If you look closely you can see that I left some parts out and added a bit of logic to allow setting
the amount of steps the brightness scale is sliced into.

## OBS -2.3
The other videoish thing we have going on sofar is this:

<blockquote class="twitter-tweet" data-lang="en">
  <a href="https://twitter.com/S0lll0s/status/876077574639767552">Video Sketch Titler</a>
</blockquote>

this *SONY Family Studio* 'Video Sketch Titler' is basically a little box that you connect inbetween
your video camera with some awesome family vacation clips on tape and your VHS recorder, which is
hooked up to your PC.

You can then draw an amazing title screen over your video with this touchpad-ish device.
When you are ready, you rewind the camera to the beginning, press play and start recording on VHS at
the same time.  Then you hit the 'fade in' and 'fade out' buttons on the Sketch Titler and go win
that home video contest.

Well, this is how it's intended to be used anyway. If your camera doesn't work (like mine), you can
instead practice on a gray background:

![][ich-bin-holz.jpg]

So ideally, we can get a live camera as an input to this, and draw on it in *real time*!
Like an ancient livestreaming tool like OBS.
(and then hopefully we will also have a Visualist to either hook up before or after this device)

Also some other people else has already circuit-bent this.
It looks amazing, so we might just give that a go aswell:

<iframe
  width="560"
  height="315"
  src="https://www.youtube.com/embed/CwVHHz3ph_c"
  frameborder="0"
  allowfullscreen
></iframe>
<iframe
  width="560"
  height="315"
  src="https://www.youtube.com/embed/odBDytzF7ko"
  frameborder="0"
  allowfullscreen
></iframe>

Since taking this for a spin and making a BOM for the *Visualist*,
I haven't spent any more time on the *Visualist* and turned to the audio side of things for now.
The next step on this front will probably be to lay out (parts of) the circuitry on stripboard and'
get ready to solder :)

[plonat-atek]:  https://s-ol.itch.io/plonat-atek
[lzx]:          https://www.lzxindustries.net/
[vfold]:        https://vfoldsynth.wordpress.com/2013/01/23/hidden-stores-of-forum-gold/
[visualist]:    https://www.dropbox.com/s/uhjd2e6gur972yo/VisualistKl.pdf?dl=0

[schematic.png]:    {{schematic+URL -> image/png}}
[mine.jpg]:         {{mine+URL -> image/jpeg}}
[ich-bin-holz.jpg]: {{ich_bin_holz+URL -> image/jpeg}}

<script async src="//platform.twitter.com/widgets.js" charset="utf-8"></script>
