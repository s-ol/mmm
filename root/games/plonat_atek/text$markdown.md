# <mmm-embed nolink facet="title"></mmm-embed>

<mmm-embed nolink path="pictures"></mmm-embed>

*Plonat Atek* is a digital game that communicates itself to the player only via the stereo headphone jack.
The signal is split, and one of the streams is fed into a pair of headphones that show the game to the player as a melody,
interlaced with a series of blips and bursts of noise.
The other stream leads into an oscilloscope, that visualises the two channels by moving a dot across the screen in correspondence to the signal.
On the screen, the game manifests as a ball bouncing around in a circular version of *Breakout*.

Both the oscilloscope and the speakers are analog devices that interpret the signal and generate a representation of the game.
The representations are based on interrelated properties of the same signal.
Thus, the relationship between the audio and visual components is not merely designed, rather the two emerge from identical information:
In *Plonat Atek*, the sound is designed to be seen and the visuals are designed to be heard.
For example the blip heard when the ball bounces is the distortion seen in the same moment,
and the noise heard when the ball is lost is visible as a glitch on the oscilloscope.

<mmm-embed nolink path="video"></mmm-embed>

## Awards and Exhibitions
*Plonat Atek* was awarded first place in the *Innovation* category, 8th in *Audio* and 24th overall at the *Ludum Dare 38 Compo* in 2017.
The project has been exhibited at *A MAZE. Berlin 2018* and *Maker Faire Rome 2019*.

## History
*Plonat Atek* was originally developed in 48 hours for the *Ludum Dare 38 Compo* in June 2017.
You can find the original submission [here][ld] and documentation on how to download and run the jam version on the [itch.io page][itch].

Articles on the game accompanied by the video recording above have been published by [Hackaday][hackaday], [VICE Motherboard][motherboard] and others.

The jam version is designed to run on an end-user Computer and is played using the keyboard.
In early 2018 I decided to build a self-contained hardware version that is played using a rotary knob.
This is the version pictured above.

## Artist Statement
*Plonat Atek* is an exploration into the unification of audiovisual signals in the context of feedback in interactive systems.
Both digital and analog audio signals are very thin encodings,
as they map directly to the vibrations on our tympana and thereby the sensations they represent.
In contrast, raster video signals or image encodings are a very contrived, optimized and complicated;
the discrete and serial pixel-per-pixel description of shapes does not come close at all to the way our human perception works.
This is also obvious as the technology required to decode a video signal or image into something a human can perceive is extremely complex.
In *Plonat Atek*, the visual output on the oscilloscope is as directly based on the waveforms encoding it as the audio is.
The thinner encoding allows the simultaneous use of the exact same signal for both the audio output on the speakers and
the visual output on the oscilloscope, thereby intrinsically connecting the two.

At the same time Plonat Atek is a media archaeological project and hommage.
The earliest video games, such as *Tennis for Two* and *Spacewar!*, as well as later arcade games like *Asteroids*,
and even consoles like the *Vectrex* share the CRT screen whose warm glow transports a unique feeling of messy analogue-ness
coupled with a homely sense of healthy imperfection.
The game itself is a reinterpretation of the classic *Breakout*, a game many players may recognize nostalgically and
that has already gone through transformations from hardware to software, and from an arcade to a pc and finally a mobile game
or something found on a children’s toy that comes free with an order at a fast-food restaurant.

[ld]: https://ldjam.com/events/ludum-dare/38/plonat-atek
[itch]: https://s-ol.itch.io/plonat-atek

[hackaday]: https://hackaday.com/2017/11/05/programming-an-oscilloscope-breakout-game-in-pure-data/
[motherboard]: https://motherboard.vice.com/en_us/article/59yw9z/watch-this-awesome-oscilloscope-breakout-game
