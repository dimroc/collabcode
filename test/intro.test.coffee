assert = require 'assert'

exports['test the ability to test'] = ->
  assert.equal 6,6

exports['test the ability to test asynchronously'] = (beforeExit) ->
  n = 0
  setTimeout ->
    ++n
    assert.ok true
  , 200

  setTimeout ->
    ++n
    assert.ok true
  , 200

  beforeExit ->
    assert.equal 2, n, 'Ensure both timeouts are called'

