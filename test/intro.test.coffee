vows = require 'vows'
assert = require 'assert'

basic_suite = vows.describe('basic tests').addBatch
  'first test':
    topic: true,
    'is run first': (topic) ->
      assert.ok topic

basic_suite.export(module)

suite = vows
  .describe('Ability to keep a Vow')
  .addBatch
    'when simply invoking a test':
      topic: 1
      'we should pass that the topic can equal 1': (topic) ->
        assert.equal 1, topic
    'when running in parallel via another context':
      topic: ->
        setTimeout @callback, 200
        return
      'we should still fulfill our vow': ->
        assert.ok true
      'even when having parallel dependencies (nested contexts)':
        topic: ->
          setTimeout => # We must use the fat arrow here to bind the this pointer to the topic context
            @callback null, false
            # We explicitly place return at the end of our callback so vows doesn't think we return a value
            return
          , 200
          return
        'we still keep our vow': (err, val) ->
          assert.ok val == false

suite.export(module)

