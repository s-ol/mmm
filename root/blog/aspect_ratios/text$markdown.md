Dealing with different screen sizes and formats can be annoying.
On desktop PCs, 16:9 is the most common aspect ratio these days, but depending on where you are rendering your content,
it might still be a different format, for example when a task bar, broswer navigation bar or similar is slicing away some of your screen real-estate.  
For mobile games the situation is a bit worse, because there are simply more different aspect ratios out there
and different systems may require extra space for on-screen navigation keys, statusbars etc.

In this post I want to present a simple technique for layouting **simple UIs for games** that can work across a range of similar screens.
If you are looking for a way to design a UI-heavy app, or something that needs to work across very different environments (like phones, tablets and desktop PCs), this is probably not what you are looking for.
In any case, if you just want to take a quick look you can jump down to the [examples](#examples) at the bottom of the page as well.

## step one: `fit`
The most trivial solution is to simply choose the aspect ratio you would like to work with,
and then fit a rectangle with that ratio into whichever space is available.
Depending on the screen, this may either be a perfect fit, leave space on the horizontal axis, or leave space on the vertical axis:
(drag the lower right corner to see this approach react to different screen sizes)

<mmm-embed path="interactive" facet="fit" nolink></mmm-embed>

This is pretty trivial to accomplish in code.
You can calculate the scales in relation to your reference grid on the x and y axis separately, and simply use the one with a lower value.
Establishing a reference grid and knowing the scale to translate between it and the physical screen sizes will also help
designing the layout in general, as we will see later.
Here is a simple example in JS:

```js
// measured from somewhere
const width = 2000;
const height = 1080;

const sx = width / 16;
const sy = height / 9;

const scale = Math.min(sx, sy);
const offset_x = width * (1 - scale);
const offset_y = height * (1 - scale);

// the biggest 16:9 rectangle you can fit is (scale*width, scale*height) large
// and it's top-left corner is at (offset_x/2, offset_y/2)
```

The problem with this is that it simply doesn't look very good.  When the ratio is a perfect match there is of course no problem,
but otherwise the empty space makes the screen look empty (especially if there are system UI elements next to it).

## step two: `perforate`
So how can this be imroved? We would like to use the unused space on the x or y axis, but we can't just scale everything up,
or we would start cropping important pieces of UI. Stretching the game to fill the screen also doesn't work for obvious reasons.

To proceed, the UI has to be 'perforated' into different sections that are independent from each other.
This is where establishing a reference grid becomes useful to orient ourselves in the layout.
In my example I am splitting the screen into a main content section that is 16:5 units large, as well as a top and bottom bar.
The two bars are also split in half vertically in the middle, for reasons that we will see in the third step.

<mmm-embed path="interactive" facet="perforate" nolink></mmm-embed>

It's imortant to note that how you divide the screen up depends completely on your game/interface of course.
The layout I am using here is just an example; at the end of this post you can find another one with a different layout as well.

## step three: `tear`

Now that the sections are defined, in the last step we can 'tear' the sections apart and decide how they should react to the
left-over space calculated in step one individiually.
In my layout, I stretch the top and bottom bars to fill the screen completely horizontally.
By dividing the bars into separate sections in the last step, I know how much space is guaranteed to be available on each side.
If there is room left on the vertical axis, I move the bars out from the center to give the content some visual space:

<mmm-embed path="interactive" facet="tear" nolink></mmm-embed>

Once again, how you make the pieces behave depends a lot on what elements your UI has in the first place, and how you want it to look and feel.

# examples

Finally, here are two examples with a bit more visual coherence to show how this actually ends up working.
You can click on these to cycle between the normal view, showing the frames used to subdivide the canvas, and viewing `fit` only for comparison.

<mmm-embed path="interactive" facet="vtk" nolink></mmm-embed>
<mmm-embed path="interactive" facet="sidebar" nolink></mmm-embed>

