So, for the first non-meta post (don't mind this line), I'm gonna walk you through my stencil creation process.

# Design
Right now, I design all my stencils in photoshop (CS6, running in wine).
If I get better at hand drawing maybe one day I will sketch them up freehand right on the material but as of now I only do that for text.

As an example, let's take the Kill Bill Stencil I did a few days ago:

<mmm-embed path="killbill_final"></mmm-embed>

The first thing I did was create a new file in Photoshop, with the dimensions set to what I can print with my inkjet printer (International - A4).
For the design process the canvas size doesn't really matter anyway and I like to work on a familiar size so I can judge how fine the details should be, also I print the images via my phone and so I need to have them in A4 size to get consistent results later anyway.

The next thing I did was look for a picture to use, after a (very) quick google images tour I settled on this image:

<mmm-embed path="poster"></mmm-embed>

In order to turn this into a stencil, I used the *Threshold* Image Adjustment, but before that I cut away all the background.
With the Magic Wand and Quick Selection, I removed the black bar and yellow background.
Because I am living in constant fear of losing work, I duplicated the layer and then popped open the *Threshold* Dialog (`Image > Adjustements > Threshold`).
I played around with the slider until I got a good ratio of light and shadow and then applied the changes.

Often some parts of the image require a different threshold setting than other parts (for example the faces often have lower contrast and require a different threshold value).
In those cases, I just duplicate the original resource layer, find the other value and then cut away the pieces that I don't need
(because I am afraid of commitment I sometimes end up masking the layers with vector masks instead).

After this step, there will be a lot of tiny artifacts and bubbles that are way too tiny to be cut out (or impossible because they would form tiny islands).
For the Kill Bill Stencil, I went over __all__ of those by hand on another layer with the pencil tool (the brush is terrible for stencilwork because you want a hard edge to cut later, not a gradient around what you drew).
However later on I realized that there is a good way to reliably eliminate this noise; all you need to do is apply a blur (*Gaussian Blur* is very effective and configurable, `Filter > Blur > Gaussian Blur`) and then re-apply *Threshold*.
You can play around with this process a bit to get a feeling for how hard you need to blur to eliminate the noise.

You will still need to manually touch up the stencil though, at least to look for and fix *Islands*;
In my case, I spraypaint black color onto a white background, so everything that is black gets cut out.
This means that every white part that is surrounded completely by black is going to fall out of the stencil together with the black aswell.
Larger islands may be taped to the surface you are spraying on for art, but it's best to avoid Islands wherever possible (and especially small ones).

To visualize the final stencil, I have looked up the exact colors of the spraypaint I own at the manufacturers website and saved them as swatches in my photoshop.
I use those to put a background behind the whole image and to color layers that I want to spraypaint in color later.

<mmm-embed path="killbillstencil"></mmm-embed>

One problem when you like working non-destructively on many layers, as I do, is that you normally cannot remove something on a layer below by painting over it.
There are two options, either you can just draw the background color, which means you will have to flatten the image later to get the outline, or you can use the *Layer Blend Modes* to your advantage:
What I did was put all the layers in a Layer Group, and set that groups *Blend Mode* to *Screen*.
This will result in everything Black staying Black and everything White turning into transparent, so now you can just paint white on a layer above one that is black to erase the one below.

# Printing
To print the stencil out, I apply a *Stroke* to all the seperate color's layers (`Layer Styles > Stroke`) and turn down the *Fill* value to 0%.
That way I save toner when printing and have a clear outline guide to cut at.
If one color is scattered across layers I either merge them or put them in a group, then apply the styles to that group instead.

Because my printer's drivers are weird I print with the phone app. I save every color's outline as a seperate JPG, push them to my phone and print them.
I used to print on standard A4 paper, tape that to thicker cardboard and cut, but I realized that my printer can actually handle the thicker cardbord paper I have.
That makes cutting a lot easier.

# Cutting
Cutting is very straightforward, I just try to get as many details as possible.
I use a standard box cutter but a scalpel / x-acto knife would probably work even better.
I have a rubber cutting mat that is specifically made for this and works very well.

<mmm-embed path="killbill_progress"></mmm-embed>

For small round holes I use an old screwdriver part that turned out to be a perfect hole-punching tool and hit it into the paper with a hammer (on a piece of wood).

# Painting
To hold down the stencils I usually tape them to the surface with painters tape.
Sometimes I just hold them or press parts flat.
If there are small, flimsy pieces inside that won't stay on the surface or that would get blown to the side or up by the aerosol, I make a small loop out of the tape and stick it to the surface with that makeshift double-sided tape.

Then I just grab the spraycans and paint the stencil with small, short strokes.
I try not to hit the same spot too often or too long so the paint doesn't flow beneath the stencil or take too long to dry.

# Results
Here are some of my stencils:

<mmm-embed path="killbill_final"></mmm-embed>
<mmm-embed path="technofist_final"></mmm-embed>
<mmm-embed path="suits_final"></mmm-embed>
<mmm-embed path="balistencil_final"></mmm-embed>

I tweet all my daily stencils with the [hashtag #astenciladay on twitter][#astenciladay] and post them in the [*Daily Stencil Art* streak on *streak.club*][dailystencil].

If you want any of the `psd`s or the printable outline `jpg`s, [shoot me a tweet][twitter]!

[#astenciladay]:        https://twitter.com/hashtag/astenciladay
[dailystencil]:         https://streak.club/s/614/daily-stencil-art
[twitter]:              https://twitter.com/S0lll0s
