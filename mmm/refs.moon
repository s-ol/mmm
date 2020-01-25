{
  depth: 0
  count: 0

  push: =>
    @depth += 1

  pop: =>
    @depth -= 1
    if @depth == 0
      @count = 0

  get: =>
    @count += 1
    @count
}
