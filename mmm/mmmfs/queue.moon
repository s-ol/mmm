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
