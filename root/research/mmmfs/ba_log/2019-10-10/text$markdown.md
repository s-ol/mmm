Today I moved the static resources needed by the web-frontend into the content of the mmmfs itself:
The server doesn't make an exception for static files anymore (as described in [a previous update][2019-10-08]),
but rather the files are just in a fileder called `static` now, and properly typed, here:

- [/static/style/](/static/style/:%20text/html+interactive)
- [/static/mmm/](/static/mmm/:%20text/html+interactive)

This removed a big exception and left the server implementation much cleaner and shorter, as can be seen in the corresponding commit [`005cc9b`][005cc9b].

I also changed the route syntax introduced in [`2019-10-08`][2019-10-08] for getting the fileder index,
now instead of being hard-coded to return a JSON value at `?index` \[[`b36a1a6`][b36a1a6]\].
`?index` is treated as a pseudo-facet that can be requested in different types, just like real facets.
I also added a second pseudo-facet `?tree`, which works like `?index`, except that it recurses and includes
all content below the current fileder, rather than just including the child-fileders.

Here are some example links for viewing these:

- [`/?index: text/html`](/?index:%20text/html)
- [`/research/mmmfs/ba_log/?index: text/html`](/research/mmmfs/ba_log/?index:%20text/html)

Finally I added a third pseudo-facet called `?interactive` that renders the Inspector that the old page ran on,
allowing to inspect raw facets, and bringing back the navbar \[[`9ab2f0f`][9ab2f0f]\].

Now that there was a way to serve the Browser to the client again, I got to work on fixing it there.
This involved a bigger changes in the shared mmm internals:

Up to this point, for each request to render a fileder, the server would load that fileder,
with all its facets and their values, as well as all children and their facets and children recursively.
That means that when the root fileder is rendered, currently 120MB of data have to be loaded from disk (or a database).
Now that the client can render content within the web browser again, that would be even worse due to the network delay.

To solve this, the Fileder implementation now lazy-loads \[[`9632233`][9632233]\].
When a Fileder is created, it initially knows only its path, but doesn't know which facets or children it contains.
As soon as that data is attempted to be accessed, the fileder loads in the list of its children and facets from the datastore.
The facet contents are loaded only when they are actually needed to fulfill a data request or conversion.

With this need for optimization taken care of, I added a new datastore (`web`) \[[`91546d1`][91546d1]\], that can run on the client.
Instead of directly accessing a database or physical file system, like the `sql` and `fs` stores, the `web` store delegates all
requests to the server APIs I have been building, such as the new `?index` pseudo-facet.

[2019-10-08]: /research/mmmfs/ba_log/2019-10-08/
[005cc9b]: https://git.s-ol.nu/mmm/commit/005cc9b3914128267017620984aee921999e173f/
[b36a1a6]: https://git.s-ol.nu/mmm/commit/b36a1a6c61a6e8bff156ce4e2dc66fe8ed8cd95e/
[9ab2f0f]: https://git.s-ol.nu/mmm/commit/9ab2f0fe3a1a043300536a057bafe5058d987d7f/
[9632233]: https://git.s-ol.nu/mmm/commit/9632233c16a26f017c648faf36a6b26833e62f2e/
[91546d1]: https://git.s-ol.nu/mmm/commit/91546d12919736b08567d7174bf1063cab0838f0/
