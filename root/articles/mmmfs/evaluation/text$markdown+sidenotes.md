evaluation
==========

## examples
In this section I will take a look at the implementations of the example for the use cases outlined above,
and evaluate them with regard to the framework derived in the corresponding section above.

### publishing and blogging
Since mmmfs has grown out of the need for a versatile CMS for a personal publishing website, it is not surprising to
see that it is still up to that job. Nevertheless it is worth taking a look at its strengths and weaknesses in this
context:

The system has proven itself perfect for publishing small- and medium-size articles and blog posts, especially for its
ability to flexibly transclude content from any source. This includes diagrams (such as in this thesis),
videos (as in the documentation in the appendix), but also less conventional media such as
interactive diagrams<mmm-embed path="../references/aspect-ratios" wrap="sidenote"></mmm-embed> or twitter postings.

<!-- @TODO -->
On the other hand, the development of the technical framework for this thesis has posed greater challenges.
In particular, the implementation of the reference and sidenote systems are brittle and uninspiring.

This is mostly due to the approach of splitting up the thesis into a multitude of fileders, and the current lack of
mechanisms to re-capture information spread throughout the resulting history effectively.
Another issue is that the system is currently based on the presumption that content can and should be interpreted
separately from its parent and context in most cases. This has made the implementation of sidenotes less idiomatic
than initially anticipated.

### pinwall
The pinwall example shows some strenghts of the mmmfs system pretty convincingly.
The type coercion layer completely abstracts away the complexities of transcluding different types of content,
and only positioning and sizing the content, as well as enabling interaction, remain to handle in the pinwall fileder.

A great benefit of the use of mmmfs versus other technology for realising this example is that the example can
seamlessly embed not only plain text, markdown, images, videos, and interactive widgets, but also follow links to all
of these types of content, and display them meaningfully. Accomplishing this with traditional frameworks would take
great effort, where mmmfs benefits from the reuse of these conversions across the whole system.

In addition, the script for the pinwall folder is 120 lines long, of which 30 lines are styling, while almost 60 lines
take care of capturing and handling JS events. The bulk of complexity is therefore shifted towards interacting with the
UI layer (in this case the browser), which could feasibly be simplified through a custom abstraction layer or the use of
output means other than the web.

### slideshow
A simplified image slideshow example consists of only 20 lines of code and demonstrates how the reactive component
framework simplifies the generation of ad-hoc UI dramatically:

```moon
import ReactiveVar, text, elements from require 'mmm.component'
import div, a, img from elements

=>
  index = ReactiveVar 1

  prev = (i) -> math.max 1, i - 1
  next = (i) -> math.min #@children, i + 1

  div {
    div {
      a 'prev', href: '#', onclick: -> index\transform prev
      index\map (i) -> text " image ##{i} "
      a 'next', href: '#', onclick: -> index\transform next
    },
    index\map (i) ->
      child = assert @children[i], "image not found!"
      img src: @children[i]\gett 'URL -> image/png'
  }
```

The presentation framework is a bit longer, but the added complexity is again required to deal with browser quirks,
such as the fullscreen API and sizing content proportionally to the viewport size.
The parts of the code dealing with the content are essentially identical, except that content is transcluded via the
more general `mmm/dom` type-interface, allowing for a greater variety of types of content to be used as slides.

## general concerns
While the system has proven pretty successful and moldable to the different use-cases that it has been tested in,
there are also limitations in the proposed system that have become obvious in developing and working with the system.
Some of these have been anticipated for some time and concrete research directions for solutions are apparent,
while others may be intrinsic limitations in the approach taken.

### global set of converts
In the current system, there is only a single, global set of *converts* that can be potentially applied to facets
anywhere in the system.
Therefore it is necessary to encode behaviour directly (as code) in facets wherever exceptional behaviour is required.
For example if a fileder conatining multiple images wants to provide custom UI for each image when viewed independently,
this code has to either be attached to every image individually (and redundantly), or added as a global convert.
To make sure this convert does not interfere with images elsewhere in the system, it would be necessary to introduce
a new type and change the images to use it, which may present even more problems, and works against the principle of
compatibility that the system has been constructed for.

A potential direction of research in the future is to allow specifying *converts* as part of the fileder tree.
Application of *converts* could then be scoped to their fileders' subtrees, such that for any facet only the *converts*
stored in the chain of its parents upwards are considered.
This way, *converts* can be added locally if they only make sense within a given context.
Additionally it could be made possible to use this mechanism to locally override *converts* inherited from
further up in the tree, for example to specialize types based on their context in the system.

<mmm-embed wrap="marginnote" path="../references/alternatives-to-trees">See also </mmm-embed>
The biggest downside to this approach would be that it  presents another pressure factor for, while also reincforcing,
the hierarchical organization of data, thereby exacerbating the limits of hierarchical structures.

### code outside of the system
At the moment, a large part of the mmmfs codebase is still separate from the content, and developed outside of mmmfs
itself. This is a result of the development process of mmmfs and was necessary to start the project as the filesystem
itself matured, but has now become a limitation of the user experience: potential users of mmmfs would generally start
by becoming familiar with the operation of mmmfs from within the system, as this is the expected (and designated)
experience developed for them. All of the code that lives outside of the mmmfs tree is therefore invisible and opaque
to them, actively limiting their understanding, and thereby the customizability, of the system.

This weakness represents a failure to (fully) implement the quality of a "Living System" as proposed by
*Ink and Switch*<mmm-embed path="../references/inkandswitch" wrap="sidenote"></mmm-embed>.

In general however, some portion of code may always have to be left outside of the system.
This also wouldn't necessarily represent a problem, but in this case it is particularily relevant
for the global set of *converts* (see above), as well as the layout used to render the web view. 
Both of these are expected to undergo changes as users adapt the system to their own content types and
domains of interest, as well as their visual identity, respectively.

### type system
The currently used type system based on strings and pattern matching has been largely satisfactory,
but has proven problematic for some anticipated use cases.
It should be considered to switch to a more intricate,
structural type system that allows encoding more concrete meta-data alongside the type,
and to match *converts* based on a more flexible scheme of pattern matching.
For example it is envisaged to store the resolution of an image file in its type.
Many *converts* might choose to ignore this additional information,
but others could use this information to generate lower-resolution 'thumbnails' of images automatically.
Using these mechanisms for example images could be requested with a maximum-resolution constraint to save on bandwidth
when embedded in other documents.

### type-coercion
By giving the system more information about the data it is dealing with,
and then relying on the system to automatically transform between data-types,
it is easy to lose track of which format data is concretely stored in.
In much the same way that the application-centric paradigm alienates users from an understanding
and feeling of ownership of their data by overemphasizing the tools in between,
the automagical coercion of data types introduces distance between the user and
an understanding of the data in the system.
This poses a threat to the transparency of the system, and potentially a lack of the "Embodiment" quality (see above).

Potential solutions could be to communicate the conversion path clearly and explicitly together with the content,
as well as making this display interactive to encourage experimentation with custom conversion queries.
Emphasising the conversion process more strongly in this way might be a way to turn this feature from an opaque
hindrance into a transparent tool. This should represent a challenge mostly in terms of UX and UI design.

### editing
Because many *converts* are not necessarily reversible, it is very hard to implement generic ways of editing stored data
in the same format it is viewed. For example, the system trivially converts markdown-formatted text sources into
viewable HTML markup, but it is hardly possible to propagate changes to the viewable HTML back to the markdown source.
This particular instance of the problem might be solvable using a Rich-Text editor, but the general problem worsens when
the conversion path becomes more complex: If the markdown source was fetched via HTTP from a remote URL (e.g. if the
facet's type was `URL -> text/markdown`), it is not possible to edit the content at all, since the only data owned by
the system is the URL string itself, which is not part of the viewable representation. Similarily, when viewing output
that is generated by code (e.g. `text/moonscript -> mmm/dom`), the code itself is not visible to the user, and if the
user wishes to change parts of the representation, the system is unable to relate these changes to elements of the code
or assist the user in doing so.

However, even where plain text is used and edited, a shortcoming of the current approach to editing is evident:
The content editor is wholly separate from the visible representation, and only facets of the currently viewed fileder
can be edited. This means that content cannot be edited in its context, which is exacerbated by the extreme
fragmentation of content that mmmfs encourages. 

As a result, interacting with the system at large is still a very different experience from editing content (and
thereby extending the system) in it. This is expected to represent a major hurdle for users getting started with the
system, and is a major shortcoming in enabling end-user programming, as set as a goal for this project.
A future iteration should carefully reconsider how editing could be integrated more holistically with the other core
concepts of the design.
