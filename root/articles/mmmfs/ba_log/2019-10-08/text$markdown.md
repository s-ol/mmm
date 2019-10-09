Today I mostly fixed the output/rendering of the 'live' server I implemented yesterday.

I changed the URL scheme, it no longer uses headers, which made it hard to link to resources through `<link>` and `<script>` tags.
Instead the path, facet-name and type are now all part of the URI:

| URI                                            | fileder path       | facet name      | type                           |
| ---------------------------------------------- | ------------------ | --------------- | ------------------------------ |
| `/fileder/facet: type/subtype -> wrapped/type` | `/path/to/fileder` | `facet`         | `type/subtype -> wrapped/type` |
| `/fileder/: some/type`                         | `/fileder`         | (default facet) | `some/type`                    |
| `/fileder/alternate:`                          | `/fileder`         | `alternate`     | `text/html` (default type)     |
| `/path`                                        | `/path`            | (default facet) | `text/html` (default type)     |
| `/`                                            | `/`                | (default facet) | `text/html` (default type)     |

The fileder-index metadata was moved to a `?index` 'pseudofacet' (e.g. `/fileder/?index`).

**EDIT 2019-10-09:**
> I will take this chance to show and hopefully explain the point of this all again:
> With the system running it is now possible to demonstrate the type-coercion that powers the system.
>
> In the system, every piece of data (the *facet*s) is stored together with it's *type*.
> When requesting data, it can of course be loaded with that *type*, yielding the data unmodified,
> but it is also possible to demand a different *type* that may be more useful to the receiving application.
>
> as an example we can take for example this article about one of the internal libraries for writing HTML documents:
> [`/meta/mmm.dom/`](/meta/mmm.dom/).
>
> The path `/meta/mmm.dom/` corresponds, according to the table above, to the default facet of the `/meta/mmm.dom` fileder,
> and since no type was specified, it is assumed that the browser wants a `text/html` document.
> The follwing path gives the same result, but makes this explicit:  
> [`/meta/mmm.dom/:text/html`](/meta/mmm.dom/:text/html)
>
> now, instead of asking for the rendered HTML document, we can also ask for the source, which is of the type
> `text/moonscript -> mmm/dom` (a Moonscript-script file that evaluates to a website-fragment):  
> [`meta/mmm.dom/:text/moonscript -> mmm/dom`](/meta/mmm.dom/:text/moonscript%20-%3E%20mmm/dom)
>
> or, we could ask for the generated html fragment, but without the full HTML layout around it -
> that would be the type `text/html+frag`, as mentioned in the last post:  
> [`meta/mmm.dom/:text/html+frag`](/meta/mmm.dom/:text/html+frag)
>
> lastly, we could also ask the system to generate a link to this content, in the `text/html` format (`URL -> text/html`):  
> [`meta/mmm.dom/:URL -> text/html`](/meta/mmm.dom/:URL%20-%3E%20text/html)  
> this might seem somewhat redundant, since we need a link to access this link,
> but it can be useful when a component cannot work with binary data directly, e.g. when mentioning or embedding an image
> or a video file.

I also added support to the server for serving static assets (e.g. the CSS stylesheet) from the `static` directory.
These files are accessible through the `/.static/` route (e.g. `/.static/main.css`), where they shouldn't interfere
with the mmmfs contents.
With the layout adjsuted to use these new paths, the live server now looks properly styled again too!

Finally I worked on the Dockerfile and my deployment a bit,
so that my updates to the code will now be automatically applied to my test site,
which is available at [ba.s-ol.nu](//ba.s-ol.nu) (which might be where you are reading this right now!).
