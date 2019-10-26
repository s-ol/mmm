Drawbacks & Future Work
-----------------------

There are multiple limitations in the proposed system that have become obvious in developing and working with the system.
Some of these have been anticipated for some time and concrete research directions for solutions are apparent,
while others may be intrinsic limitations in the approach taken.

### global set of converts
In the current system, there exists only a single, global set of *converts* that can be potentially applied
to facets anywhere in the system.
Therefore it is necessary to encode behaviour directly (as code) in facets wherever exceptional behaviour is required.
For example if a fileder conatining multiple images wants to provide custom UI for each image when viewed independently,
this code has to either be attached to every image individually (and redundantly), or added as a global convert.
To make sure this convert does not interfere with images elsewhere in the system, it would be necessary to introduce
a new type and change the images to use it, which may present yet more propblems and works against the principle of
compatibility the system has been constructed for.

A potential direction of research in the future is to allow specifying *converts* as part of the fileder tree.
Application of *converts* could then be scoped to their fileders' subtrees, such that for any facet only the *converts*
stored in the chain of its parents upwards are considered.
This way, *converts* can be added locally if they only make sense within a given context.
Additionally it could be made possible to use this mechanism to locally override *converts* inherited from
further up in the tree, for example to specialize types based on their context in the system.

### code outside of the system
At the moment, a large part of the mmmfs codebase is still separate from the content, and developed outside of mmmfs itself.
This is a result of the development process of mmmfs and was necessary to start the project as the filesystem itself matured,
but has become a limitation of the user experience now:
Potential users of mmmfs would generally start by becoming familiar with the operation of mmmfs from within the system,
as this is the expected (and designated) experience developed for them.
All of the code that lives outside of the mmmfs tree is therefore invisible and opaque to them,
actively limiting their understanding of, and the customizability of the system.

This is particularily relevant for the global set of *converts*, and the layout used to render the web view, 
which are expected to undergo changes as users adapt the system to their own content types and domains of interest,
as well as their visual identity, respectively.

### superficial type system
The currently used type system based on strings and pattern matching has been largely satisfactory,
but has proven problematic for satisfying some anticipated use cases.
It should be considered to switch to a more intricate, structural type system that allows encoding more concrete meta-data
alongside the type, and to match *converts* based on a more flexible scheme of pattern matching.
For example it is envisaged to store the resolution of an image file in its type.
Many *converts* might choose to ignore this additional information,
but others could use this information to generate lower-resolution 'thumbnails' of images automatically.
Using these mechanisms for example images could be requested with a maximum-resolution constraint to save on bandwidth
when embedded in other documents.

### type-coercion alienates
By giving the system more information about the data it is dealing with,
and then relying on the system to automatically transform between data-types,
it is easy to lose track of which format data is concretely stored in.
In much the same way that the application-centric paradigm alienates users from an understanding
and feeling of ownership of their data by overemphasizing the tools in between,
the automagical coercion of data types introduces distance between the user and an understanding of the data in the system.
It remains to be seen whether this can be mitigated with careful UX and UI design.

### discrepancy between viewing/interacting and editing of content
Because many *converts* are not necessarily reversible,
it is very hard to implement generic ways of editing stored data in the same format it is viewed.
For example, the system trivially converts markdown-formatted text sources into viewable HTML markup,
but it is hardly possible to propagate changes to the viewable HTML back to the markdown source.
This problem worsens when the conversion path becomes more complex:
If the markdown source was fetched via HTTP from a remote URL (e.g. if the facet's type was `URL -> text/markdown`),
it is not possible to edit the content at all, since the only data owned by the system is the URL string itself,
which is not part of the viewable representation at all.
Similarily, when viewing output that is generated by code (e.g. `text/moonscript -> mmm/dom`),
the code itself is not visible to the user when interacting with the viewable representation,
and if the user wishes to change parts of the representation the system is unable to relate these changes to elements
of the code or assist the user in doing so.
As a result, the experiences of interacting with the system at large is still a very different experience than 
editing content (and thereby extending the system) in it.
This is expected to represent a major hurdle for users getting started with the system,
and is a major shortcoming in enabling end-user programming as set as a goal for this project.
