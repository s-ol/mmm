| notice | this project has moved to a new home: [`git.s-ol.nu/mmm`](//git.s-ol.nu/mmm). This github archive will however be kept up-to-date: If you want to browse it here, switch on over to the [`master`](//github.com/s-ol/mmm/tree/master/) branch. |
| ------ | --- |

---

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

Running or Building
-------------------
You can run the interactive server (`build/server.moon`):

    $ moon build/server.moon fs

You can then view the website in your browser.
It should be availabe at `http://localhost:8000`.

Alternatively, `build/render_all.moon` can be used to generate a static HTML version of a tree:

    $ moon build/render_all.moon fs output-dir /root/path

The `/root/path/` argument is optional and needs to be set if the generated HTML will not be
served from the root `/` of a server (which is assumed per default).

### Storage
The `fs` argument in the commands above specifies where and how the content is to be found.
The argument consists first of the type of storage,
and then optionally extra arguments separated by a colon (`:`).
The following types are available:

- `fs:[path]`: load a directory from the filesystem. +
   `path` is the path of the root directory, relative to the current directory.
   If omitted, defaults to `root`.
- `sql:[path]`: load a SQLite3 database. +
   `path` is the path to the sqlite database file.
   If omitted, defaults to `db.sqlite3`.
- `sql:MEMORY`: create an emptry in-memory SQLite3 database.

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
[entr][entr] is useful for reloading the realtime server when code outside the `root` changes:

    $ ls {build,mmm}/**.moon | entr -r moon build/server.moon fs

[moonscript]: https://moonscript.org/
[mmm]: https://mmm.s-ol.nu/
[entr]: http://eradman.com/entrproject/
