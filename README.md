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

Then you can run the interactive server (`build/server.moon`):

    $ moon build/server.moon fs

You can then view the website in your browser.
It should be availabe at `http://localhost:8000`.

### Dependencies

Required dependencies:

- [MoonScript][moonscript]: `luarocks install moonscript`
- [lua-http](https://github.com/daurnimator/lua-http): `luarocks install http`

For unit tests:

- [busted](https://olivinelabs.com/busted/): `luarocks install busted`

Not required but recommended:

- [lua-sqlite3](https://luarocks.org/modules/moteus/sqlite3): `luarocks install sqlite3` (for SQLite3 backend)
- [lua-cjson](https://www.kyne.com.au/~mark/software/lua-cjson.php): `luarocks install lua-cjson 2.1.0-1` (for server-side JSON support)
- [discount](https://luarocks.org/modules/craigb/discount): `luarocks install discount` (requires libmarkdown2, for Markdown support)
- [luaposix](https://luarocks.org/modules/gvvaughan/luaposix): `luarocks install luaposix` (for SASS support)

### Live Reloading (during development)
During development you may want to automatically rebuild the project as files are changed.
You can let tup automatically rebuild the client runtime and stylesheet with the following command:

    $ tup monitor -f -a

[entr][entr] is useful for reloading the realtime server when code outside the root changes:

    $ ls {build,mmm}/**.moon | entr -r moon build/server.moon fs

[moonscript]: https://moonscript.org/
[mmm]: https://mmm.s-ol.nu/
[tup]: https://gittup.org/tup
[entr]: http://eradman.com/entrproject/
