Today I mostly fixed the output/rendering of the 'live' server I implemented yesterday.

I changed the URL scheme, it no longer uses headers, which made it hard to link to resources through `<link>` and `<script>` tags.
Instead the path, facet-name and type are now all part of the URI:

| URI                                            | fileder path       | facet name      | type                           |
| ---------------------------------------------- | ------------------ | --------------- | ------------------------------ |
| `/fileder/facet: type/subtype -> wrapped/type` | `/path/to/fileder` | `facet`         | `type/subtype -> wrapped/type` |
| `/fileder/: some/type`                         | `/fileder`         | (default facet) | `some/type`                    |
| `/fileder/alternate:`                          | `/fileder`         | `alternate`     | `text/html` (default type)     |
| `/`                                            | `/`                | (default facet) | `text/html` (default type)     |

The fileder-index metadata was moved to a `?index` 'pseudofacet' (e.g. `/fileder/?index`).

I also added support to the server for serving static assets (e.g. the CSS stylesheet) from the `static` directory.
These files are accessible through the `/.static/` route (e.g. `/.static/main.css`), where they shouldn't interfere
with the mmmfs contents.
With the layout adjsuted to use these new paths, the live server now looks properly styled again too!

Finally I worked on the Dockerfile and my deployment a bit,
so that my updates to the code will now be automatically applied to my test site,
which is available at [ba.s-ol.nu](//ba.s-ol.nu) (which might be where you are reading this right now!).
