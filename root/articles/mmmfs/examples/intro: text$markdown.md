# examples
To illustrate the capabilities of the proposed system, and to compare the results with the framework introduced above,
a number of example use cases have been chosen and implemented from the perspective of a user.
In the following section I will introduce these use cases and briefly summarize the implementation
approach in terms of the capabilities of the proposed system.

## Publishing and Blogging
Blogging is pretty straightforward, since it generally just involves publishing lightly-formatted text,
interspersed with media such as images and videos or perhaps social media posts.
Markdown is a great tool for this job, and has been integrated in the system to much success:
There are two different types registered with *converts*: `text/markdown` and `text/markdown+span`.
They both render to HTML (and DOM nodes), so they are immediately viewable as part of the system.
The only difference for `text/markdown+span` is that it is limited to a single line,
and doesn't render as a paragraph but rather just a line of text.
This makes it suitable for denoting formatted-text titles and other small strings of text. 

The problem of embedding other content together with text comfortably is also solved easily,
becase Markdown allows embedding arbitrary HTML in the document.
This made it possible to define a set of pseudo-HTML elements in the Markdown-convert,
`<mmm-embed>` and `<mmm-link>`, which respectively embed and link to other content native to mmm.

## Pinwall
In many situations, in particular for creative work, it is often useful to compile resources of
different types for reference or inspiration, and arrange them spacially so that they can be viewed
at a glance or organized into different contexts etc.
Such a pinwall could serve for example to organise references to articles,
to collect visual inspiration for a moodboard etc.

As a collection, the Pinwall is primarily mapped to a Fileder in the system.
Any content that is placed within can then be rendered by the Pinwall,
which can constrain every piece of content to a rectangular piece on its canvas.
This is possible through a simple script, e.g. of the type `text/moonscript -> fn -> mmm/dom`,
which enumerates the list of children, wraps each in such a rectangular container,
and outputs the list of containers as DOM elements.

The position and size of each panel are stored in an ad-hoc facet, encoded in the JSON data format:
`pinwall_info: text/json`. This facet can then set on each child and accessed whenever the script is called
to render the children, plugging the values within the facet into the visual styling of the document.

The script can also set event handlers that react to user input while the document is loaded,
and allow the user to reposition and resize the individual pinwall items by clicking and dragging
on the upper border or lower right-hand corner respectively.
Whenever a change is made the event handler can then update the value in the `pinwall_info` facet,
so that the script places the content at the updated position and size next time it is invoked.

## Slideshow
Another common use of digital documents is as aids in a verbal presentation.
These often take the form of slideshows, for the creation of which a number of established applications exist.
In simple terms, a slideshow is simply a linear series of screen-sized documents, that can be
advanced (and rewound) one by one using keypresses.

The implementation of this is rather straightforward as well.
The slideshow as a whole becomes a fileder with a script that generates a designated viewport rectangle,
as well as a control interface with keys for advancing the active slide.
It also allows putting the browser into fullscreen mode to maximise screenspace and remove  visual elements
of the website that may distract from the presentation, and register an event handler for keyboard accelerators
for moving through the presentation.

Finally the script simply embeds the first of its child-fileders into the viewport rect.
One the current slide is changed, the next embedded child is simply chosen.

## Code Documentation
/meta/mmm.dom/:%20text/html+interactive
