mmm
===
mmm is not the www, because it runs on [MoonScript][moonscript].

live version at [mmm.s-ol.nu][mmm].

Building & Viewing
------------------
mmm is built using [tup][tup].  
You can build the static content with:

    $ tup init
    $ tup

Then, run some kind of HTTP server from within `dist`, e.g. with python 3 installed:

    $ cd dist
    $ python -m http.server

You can then view the website in your browser.
The example above will provide it at `http://localhost:8000`.

During development you may want to automatically rebuild the project as files are changed.
You can do this with the following command:

    $ tup monitor -f -a

[moonscript]: https://moonscript.org/
[mmm]: https://mmm.s-ol.nu/
[tup]: https://gittup.org/tup
