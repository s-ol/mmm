Besides some smaller fixes with the styling of the page, and in particular the diagrams introduced in [`2019-10-24`][2019-10-24],
I finally (re-)implemented children-ordering in the `fs`-store of mmmmfs
(the `sql` store is still missing it, but I am not currently using it either) \[[`a62f63b`][a62f63b]\]:
Files on the regular filesystem don't have a particular order, but in mmmfs the order of children is is guaranteed,
so that arranging children in a particular order becomes a meaningful tool.

To store the ordering data, a 'magic' file called `$order` is (optionally) stored in each directory in the filesystem.
The file lists all child fileders by name in the given order.
When the children of a fileder are requested (in `list_fileders_in` or `get_index`, which relies on the former),
all children that are mentioned in `$order` are returned in that order,
while all remaining children are sorted alphabetically and appended at the end of the list.
This way the order is guaranteed to be stable even if no `$order` file is specified,
or when the `$order` file has not been updated after adding new children.

Here is the commented implementation in MoonScript:

      list_fileders_in: (path='') =>
        -- create a mapping of all child-fileders
        -- in 'entries' (name -> path)
        entries = {}
        for entry_name in lfs.dir @root .. path
          continue if '.' == entry_name\sub 1, 1
          entry_path = @root .. "#{path}/#{entry_name}"
          if 'directory' ~= lfs.attributes entry_path, 'mode'
            continue

          entries[entry_name] = "#{path}/#{entry_name}"

        -- where we will store our sorted list of children
        sorted = {}

        -- check for existance of the order file
        order_file = @root .. "#{path}/$order"
        if 'file' == lfs.attributes order_file, 'mode'
          for line in io.lines order_file
            path = assert entries[line], "entry in $order but not on disk: #{line}"
            
            -- add all $order-entries to the sorted output in the same order they appear.
            -- also flag these entries as already added
            table.insert sorted, path
            sorted[line] = true

        -- find the he remaining (non-flagged) entries, sort them alphabetically
        -- and then append them to the sorted output list
        entries = [path for entry, path in pairs entries when not sorted[entry]]
        table.sort entries
        for path in *entries
          table.insert sorted, path

        -- return an iterator over the sorted output
        coroutine.wrap ->
          for path in *sorted
            coroutine.yield path

The interface for reordering fileders is still missing in the code,
and just while writing this I realized that the current implementation is in fact buggy:
when a fileder that is mentioned in `$order` is deleted via the `stores.fs` API,
it is not removed from `$order`, causing an error the next time the fileder is listed.
I will probably get around to fixing both of these problems when I build the corresponding UI.

[2019-10-24]: /articles/mmmfs/ba_log/2019-10-24/
[a62f63b]: https://git.s-ol.nu/mmm/commit/a62f63bc00cd63a98b349a2574e3e9e14c95a441/
