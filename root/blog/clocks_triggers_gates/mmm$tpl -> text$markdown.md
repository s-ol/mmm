A classic module in modular synthesisers is a sequencer. It allows you to create rhythms and
melodies by letting you set a sequence of values to output over some time.
For example a drum machine usually contains a step-sequencer where for every *step* in the
*sequence* you can select whether to play, or not play, a drum.

*CV Sequencers* haver a dial in place of that on/off switch, where you can set a value for the
*Control_Voltage* to be output.
That signal can then be fed into another module to do something interesting, like control the
pitch of an oscillator, the cut-off point of a filter or the gain of an amplifier.

Sequencers usually have an internal clock, with a dial to set the speed, but also an external clock
input, where you can feed in a square wave signal.
Every time the square wave goes from low (0V) to high (usually anything over 5V) the sequencer steps
to the next beat.

Since we have a multitude of sound-generators that we want to use in interesing rhythms, multiple
sequencers sound natural and a central clock could certainly help.

## hit it
However a digital, steady clock is pretty boring, so I came up with an idea.
I remembered the old wooden metronome that my grandma had at her piano and how I used to play with
it as a child.  If we had a real metronome tick away, we could hold the needle in place,
tap it to add an extra beat where there wasn't supposed to be one and more.

<mmm-embed path="metronome"></mmm-embed>

Analog metronomes like this are actually pretty interesting little devices.
They are purely mechanical and contain a spring that you have to wind up to give it power.
On the front there is a needle with a weight at the top and the bottom.
By moving the top weight up and down the speed of the needle,
and thereby the ticking-rate can be set.
Every time the needle centers (like it is on the image below), a mechanism in the back makes a small
metal pin slam against a metal plate glued to the case, making a loud clicking noise.

With this idea, we were on the lookout for a metronome on our trip to the fleamarket
but couldn't find one, so I ended up buying the tiny one above (the size is pretty nice anyway).

The idea was (and it worked out that way!) to pick up the clicks somehow and use them to trigger
sequencers.
Originally I thought about putting a light dependant resistor (LDR) somewhere under the
counterweight, and measure the shadow as a signal.
In the time until I got the Metronome, I discussed this with Sam Battle, who runs the awesome
youtube channel [LOOK MUM NO COMPUTER][no-computer] and he proposed to use a piezo crystal
(sometimes referred to as *Contact Mic*) instead.

As it turns out, the metronome has plenty of space to glue the piezo right next to the metal plate
that the metronome hits with the metal pin, where it can pick up all that very nicely.
The 1/4" (6.3mm) audio jack also fit very well behind the panel, where there is a rather large
empty compartment, I guess to amplifiy the ticking sound.
I just drilled a hole in the back, screwed the jack in and soldered two wires; done!

<blockquote class="twitter-tweet" data-lang="en">
  <a href="https://twitter.com/S0lll0s/status/878328052744241152">First Test</a>
</blockquote>

In this first test you can see the Piezo work as a microphone amplifying the ticking noise on my
speakers.

## signal shapes
That was a first success, but the signal we get from the metronome is not very clean.
Not only does it pick up random noises from the environment (sometimes intentionally),
the click is no square wave since it resonates through the plastic material.

To clean up the signal initially I took a look on it on the Oscilloscope.
It looks pretty much like what you would expect, swinging up and down a few times,
each with a drastic drop in amplitude.

The first attempt was to just use a comparator.
The output from the metronome goes to the non-inverting-input, meaning that when it is higher than
the other (inverting) input, the output of the comparator swings high.
This is what I wanted since sequencers trigger on the rising edge.
The inverting input is wired to a potentiometers center pin, with the other two pins at the supply
voltage and ground (0 and 9V) to form a voltage divider that lets me tune the threshold to any
any voltage in that range.
The output signal is now what you would call a *Trigger* signal; it is usually low and sometimes
jumps up to 9V for a *very short* duration (while the tick clips over the threshold on it's first
and loudest swing).  I didn't measure the pulse length, but it's probably under 10ms long.

To test the circuit, I fed the output to a (CD)4017 counter.
This IC can be used to build  sequencers or clock dividers rather easily (more on that later).
I just set it up to light up 4 LEDs in sequence, so that I could see whether the circuit was fine.
After an hour or so of figuring out stupid wiring mistakes and learning about open-drain outputs
it was working:

<blockquote class="twitter-tweet" data-lang="en">
  <a href="https://twitter.com/S0lll0s/status/879046250880008193">analog metronome</a>
</blockquote>
(this tweet is mislabeled, Juan's sequencer is in the next video).

[Juan][juan] had an Akai Tomcat drum machine on hand, and we were stoked to try it out.
As usual at first, it didn't work at all.
Pretty soon we figured out that the signal was just too quiet coming off our 9V supply,
so we put an amplifier in between (alongside a whole mess of cables) and behold:

<blockquote class="twitter-tweet" data-lang="en">
  <a href="https://twitter.com/S0lll0s/status/879061152520699904">analog metronome</a>
</blockquote>

This worked pretty well, surprisingly!
With the potentiometer set *just right*, it rarely triggered twice, and ran for some time before the
spring weakened and the sound became a tiny bit more quiet and failed to trigger every beat.
This is also a really nice effect actually and transforms rather simple beats into nice wacky ones:

<blockquote class="twitter-tweet" data-lang="en">
  <a href="https://twitter.com/S0lll0s/status/879072879924711426">analog metronome</a>
</blockquote>

The schematic at this point is very simple:

<mmm-embed path="threshold"></mmm-embed>

I used an LM393 dual comparator and tied the unused half to ground, as the datasheet recommends.

## dividing time
While this was working very well already, I had an idea for improving it using the universal 555
timer IC.  However, I didn't have any 555s on hand (or rather, I wasn't aware [Ludonaut][ludonaut]
had a 556 in his box next to me) so I kept that in mind but went on with other things
(more on this in the upcoming post).

Reading up on synthesizer modules, I found *Clock Dividers* rather often. In the beginning I wasn't
quite sure what they were, but it turns out they are pretty simple: basically they just slow down a
clock (signal) by counting beats and only producing one of their own every N beats in the incoming
signal. I thought this would be very useful for us, since using clock dividers with non-multiple
divisons such as /3, /4 and /5 can create nice polyrhythms.

My plan is to build this right into the same box as the clock threshold circuitry.
In the videos above you can already see it working with /2, /3, /4 and /6 outputs.
The schematic is largely copied from [Ken Stone's amazing synthesizer project, CGS][cgs].
He has a nice collection of synth module circuits, and here I am using the pulse divider part of the
[CGS36 Pulse Divider and Boolean Logic][cgs36] module:

[![CGS36 Pulse Divider][cgs36-schematic.gif]][cgs36]

For now I left out the /7, /8 and /5 parts, but I think the /5 would be useful since it introduces
another prime division that is not much faster or slower than the /3 and /4 we already have.
The /8 would be almost 'for free' since it doesn't require a new 4017, but I'm not sure whether I
should put it in with the /7 missing. I guess it could be useful for a slow melody sequencer.

[no-computer]:  https://www.youtube.com/watch?v=fO1nbHoEZMw
[juan]:         https://twitter.com/juanorloz
[ludonaut]:     https://twitter.com/ludonaut
[cgs]:          http://www.cgs.synth.net/modules/
[cgs36]:        http://www.elby-designs.com/webtek/cgs/cgs36/cgs36_pulse_divider.html

[cgs36-schematic.gif]:  http://www.elby-designs.com/webtek/cgs/cgs36/schem_cgs36v14_pulse_divider.gif
