class Cache
  new: =>
    @cache = {}

  get: (fileder, key) =>
    key = tostring key
    @cache[fileder.path] or= {}
    @cache[fileder.path][key]

  set: (fileder, key, val) =>
    key = tostring key
    @cache[fileder.path] or= {}
    @cache[fileder.path][key] = val


init_cache = ->
  export CACHE
  CACHE = Cache!

{
  :init_cache
}
