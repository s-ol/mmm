Today I started working on the HTTP server that finds, converts and serves content stored in the (SQL) backend just-in-time (later the server could also cache content).

The server can handle these types of requests:

## Fileder Index Requests
A request like `GET /path/to/fileder/` (note the trailing slash) is used to query the contents of a fileder.
It solicits a JSON-encoded response that contains the full paths to all children of this fileder, as well as all facets currently stored, e.g:

    {
      "children": [
        "/projects/vcv_mods",
        "/projects/HowDoIOS",
        "/projects/iii-telefoni",
        "/projects/btrktrl",
        "/projects/demoloops",
        "/projects/VJmidiKit",
        "/projects/gayngine",
        "/projects/themer",
        "/projects/chimpanzee_bukkaque"
      ],
      "facets": [
        ["", "text/moonscript -> fn -> mmm/dom"],
        ["name", "alpha"],
        ["title", "text/plain"]
      ]
    }

## Facet Requests
A request like `GET /path/to/fileder/facet_name` is used to query a facet.
To differentiate a request for the 'unnamed' facet from an index request, unnamed facets are represented as a `:` character instead.
The type to ask for can be specified in a `MMM-Accept` header separately, it defaults to `text/html`.

The server either sends back the (possibly converted) facet with a `200 OK` status,
or a `406 Not Acceptable` error if no conversion was possible.

I also restructured the code a bit and moved some of the HTML-rendering code into the main mmmfs code.
Then I renamed the `text/html` type to `text/html+frag`, since it refers to only a fragment of HTML code, not a whole document,
and added a new *convert* from `text/html+frag` to `text/html` that wraps the fragment in the HTML template and style.

the full code change is in commits [81e143f](https://git.s-ol.nu/mmm/commit/81e143fa8181a6adb58d7fba632bd31a13164410/) and [ad26c7c](https://git.s-ol.nu/mmm/commit/ad26c7c4e374f66a978f9946bbb083377f2224a6/)
