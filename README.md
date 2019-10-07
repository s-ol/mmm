mmm
===
mmm is not the www, because it runs on [MoonScript][moonscript].

live version at [mmm.s-ol.nu][mmm].

What?
-----
This repo is roughly split into three parts:

- `mmm.dom`, `mmm.component`: polymorphic Lua/Moonscript modules for web development.  
  \[[code: `mmm`](mmm) - [docs](https://mmm.s-ol.nu/meta)\]
- `mmmfs`: the CMS/FS powering [mmm.s-ol.nu](https://mmm.s-ol.nu).  
  \[[code: `mmm/mmmfs`](mmm/mmmfs) - [article](https://mmm.s-ol.nu/articles/mmmfs)\]
- the page contents: includes my portfolio, blog, experiments...  
  authored using a mix of Moonscript, Markdown and HTML, thanks to the power of `mmmfs`.  
  \[[data: `root`](root), but you might want to read a bit about mmmfs before you jump in.]

Building & Viewing
------------------
mmm is built using [tup][tup].  
You can build the static content with:

    $ tup init
    $ tup

Next you can render a sqlite3 mmmfs database using

    $ moon build/render_all.moon db.sqlite3

Then, run some kind of HTTP server from within `out`, e.g. with python 3 installed:

    $ cd root
    $ python -m http.server

You can then view the website in your browser.
The example above will provide it at `http://localhost:8000`.

During development you may want to automatically rebuild the project as files are changed.
You can do this with the following command:

    $ tup monitor -f -a

### Dependencies
You will need:

- [MoonScript][moonscript]: `luarocks install moonscript`
- [lua-sqlite3](https://luarocks.org/modules/moteus/sqlite3): `luarocks install sqlite3`
- [discount](https://luarocks.org/modules/craigb/discount): `luarocks install discount` (requires libmarkdown2)
- [busted](https://olivinelabs.com/busted/): `luarocks install busted` (for testing only)

[moonscript]: https://moonscript.org/
[mmm]: https://mmm.s-ol.nu/
[tup]: https://gittup.org/tup
