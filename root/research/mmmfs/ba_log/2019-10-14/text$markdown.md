I finally added a better type-conversion-path-finding algorithm \[[`deb21aa`][deb21aa]\].
The old algorithm only took into consideration how many steps it took to get from type A (stored on disk) to type B (requested).
This could lead to problems, for example in this situation:

On Disk: `text/moonscript -> fn -> mmm/dom` (a moonscript file that contains a function that returns a bit of UI)  
Requested: `mmm/dom`  
Known Conversions:
1. `text/moonscript` to `mmm/dom` (displays the source code with highlighting)
2. `text/moonscript -> ???` to `???` (evaluates the moonscript file)
3. `fn -> ???` to `???` (calls the function, providing access to children and other facets)

Since conversion 1 only takes a single step, it would have been preferred by the old algorithm (although there were workarounds for this).
The new algorithm adds the concept of conversion-cost, that has to be specified for each conversion.
The conversions 2 and 3 now have a cost of `1`, while conversion 1 has a cost of `5`.
The conversions are simply added up and the path with the lowest cost is chosen.
Like in other pathfinding applications like digital games, the cost metric is also used by the algorithm to enhance the search itself,
it prioritises searching further on the path with the least current cost.

To implement this optimization I implemented a priority queue:

    -- a priority queue with an index
    -- only one element with a given key may exist at a time
    -- when an element with an existing key is added,
    -- the element with lower priority survives.
    class Queue
      new: =>
        @values = {}
        @index = {}

      -- add a value with a given priority to the queue
      -- if no key is specified, assume the element is uniq
      add: (value, priority, key) =>
        entry = { :value, :key, :priority }

        if key
          if old_entry = @index[key]
            -- already have an entry for this key
            -- if it is lower priority, we leave it there and do nothing
            if old_entry.priority < priority
              return

            -- otherwise we remove the old one and continue as normal
            -- find the index of the old entry
            local i
            for ii, entry in ipairs @values
              if entry == old_entry
                i = ii
                break

            -- remove it
            table.remove @values, i

          -- store this entry in the index
          @index[key] = entry

        -- store lowest priority last
        for i, v in ipairs @values
          if v.priority < priority
            -- i is the first key that is lower,
            -- we want to insert right before it
            table.insert @values, i, entry
            return

        -- couldn't find a key with a lower priority,
        -- so insert at the end
        table.insert @values, entry

      peek: =>
        entry = @values[#@values]
        if entry
          { :value, :priority, :key } = entry
          @index[key] = nil if key
          value, priority

      pop: =>
        entry = table.remove @values
        if entry
          { :value, :priority, :key } = entry
          @index[key] = nil if key
          value, priority

      -- iterator, yields (value, priority), low priority first
      poll: => @.pop, @
      
    {
      :Queue
    }

This priority queue behaves mostly as expected, but I added an extra feature to make sure that only the
best conversion path to a specific type is considered for further searching:
When adding a new element to the Queue, an extra `key` can be passed.
If a key is passed, the Queue makes sure that there is only ever one element with that key in the queue.
When a second element would be introduced, the queue discards whichever element has a higher priority value.

This way I can use the type that a conversion path leads to as the key,
and the queue will automatically discard a worse solution if a better one is found that leads to the same type result.

To make sure the Queue implementation was solid, I also added unit tests for it: [`spec/queue_spec.moon`][spec]

[deb21aa]: https://git.s-ol.nu/mmm/commit/deb21aa43fe8bf11eb276803973b272913b7e716/
[spec]: https://git.s-ol.nu/mmm/blob/deb21aa43fe8bf11eb276803973b272913b7e716/spec/queue_spec.moon
