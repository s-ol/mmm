import Queue from require 'mmm.mmmfs.queue'

describe "Queue", ->
  it "stores things", ->
    queue = Queue!
    queue\add "test", 1
    queue\add "toast", 2
    queue\add "spice", 3

    assert.is.equal "test", queue\pop!
    assert.is.equal "toast", queue\pop!
    assert.is.equal "spice", queue\pop!
    assert.is.nil queue\pop!

  it "doesnt care about the order", ->
    queue = Queue!
    queue\add "spice", 3
    queue\add "test", 1
    queue\add "toast", 2

    assert.is.equal "test", queue\pop!
    assert.is.equal "toast", queue\pop!

    queue\add "pepper", 5
    queue\add "salt", .5
    assert.is.equal "salt", queue\pop!
    assert.is.equal "spice", queue\pop!
    assert.is.equal "pepper", queue\pop!

  it "can be peeked", ->
    queue = Queue!
    queue\add "spice", 3
    queue\add "test", 1
    queue\add "toast", 2

    assert.is.equal "test", queue\peek!
    assert.is.equal "test", queue\pop!
    queue\pop!

    queue\add "pepper", 5
    queue\add "salt", .5

    assert.is.equal "salt", queue\peek!
    queue\pop!
    queue\pop!

    assert.is.equal "pepper", queue\peek!
    queue\pop!

    assert.is.nil queue\peek!

  it "keeps keys in an index", ->
    queue = Queue!
    queue\add "test", 1, 'test'
    queue\add "toast", 2, 'toast'
    queue\add "spice", 3, 'spice'

    assert.is.equal "test", queue\peek!
    queue\add "spice2", .5, 'spice'
    assert.is.equal "spice2", queue\pop!
    assert.is.equal "test", queue\pop!

    queue\add "bad toast", 5, 'toast'
    assert.is.equal "toast", queue\pop!
    assert.is.nil queue\pop!

  it "provides an iterator", ->
    queue = Queue!
    queue\add "test", 1
    queue\add "spice", 3
    queue\add "toast", 2

    expect = {'test', 'toast', 'late', 'spice'}
    expect_next = 1
    report = spy.new (v, i) ->
      assert.is.equal expect[expect_next], v
      expect_next += 1

    for value, prio in queue\poll!
      report value, prio

      if value == 'toast'
        queue\add "late", 0.5

    assert.stub(report).was.called_with('test', 1)
    assert.stub(report).was.called_with('toast', 2)
    assert.stub(report).was.called_with('spice', 3)
    assert.stub(report).was.called_with('late', 0.5)
