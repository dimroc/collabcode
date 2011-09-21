vows = require 'vows'
assert = require 'assert'
model_factory = require '../models'

test_code = 'deadbeef'
test_user = 'unittest-user'

models_suite = vows.describe('Creating the data layer').addBatch
  # Clear database and insert fixture
  "Given we can connect to the database":
    topic: -> 
      @callback null, model_factory.create_collab_docs()
    "we should have a collection object": (err, collab_docs) ->
      console.log '[TRACE] in callback for having a collection object'
      assert.isObject collab_docs

    "given we've attempted to set a locker":
      topic: (collab_docs) ->
        collab_docs.set_locker test_code, test_user
        return collab_docs

      "given that we can retrieve said locker":
        topic: (err, collab_docs) ->
          collab_docs.get_locker test_code, @callback
          return

        "vow that the locker set equals the locker got": (err, val) ->
          assert.equal test_user, val.locker
          return

models_suite.export(module)
