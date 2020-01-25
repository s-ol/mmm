Yesterday I got client-side access to the whole mmmfs tree to work via the new `web` datastore,
but the requests were still extremely inefficient.
This was because the organisation of the interface between the `Fileder` implementation and the datastore,
which required the Fileder to make two separate requests to `?index` to fetch its children and facets,
and also couldn't take advantage of the `?tree` pseudo-facet to bundle together multiple indexes in a single request.

To fix this I added a new datastore method called `get_index` that returns both facet and child information \[[`e2a4257`][e2a4257]\]
The Fileder implementation now uses this method instead of asking individually for the two pieces of information
when lazy-loading fileder contents.
The `get_index` method can also be instructed to recursively load to a fixed depth.
A Fileder can also be instantiated using such a nested index,
which causes it to immediately preload up to the same depth without the need for fetching more data.
This allows some more optimizations, like having the client preload 3-levels deep when it launches,
which seems like a decent heuristic of the data actually required for most pages and minimizes load time.

I also added some tests for the `Key` class that I use in many different places to represent facet names and types \[[`782d072`][782d072]\]].

The `?interactive` pseudo-facet from yesterday was changed to the `text/html+interactive` type instead \[[`8cdf5d4`][8cdf5d4]\].
This was a bit of a tough decision, because it is a bit un-idiomatic: rendering the browser page still requires an exception in the browser.
In the end the motivation for the change was that it should be possible,
for user ergonomics, to link to the interactive view of a given facet of a given fileder.
With `?interactive` being a facet, it wasn't possible to specify the facet without jumping out of the adressing system.
With these updates on the other hand it is possible to link fo example:

- to the main content of the root fileder, as an interactive view: [`/: text/html+interactive`](/:%20text/html+interactive)
- to the page title of the root fileder, as an interactive view: [`/title: text/html+interactive`](/title:%20text/html+interactive)

[e2a4257]: https://git.s-ol.nu/mmm/commit/e2a4257fc05d37822df2b7bbe0f587645375edf2/
[782d072]: https://git.s-ol.nu/mmm/commit/782d0725f3f29eaa7d4a12213fb00c6643795348/
[8cdf5d4]: https://git.s-ol.nu/mmm/commit/8cdf5d4a363ba99a6356e7e1dfe0dfb39e6fb13e/
