vows = require 'vows'
assert = require 'assert'
model_factory = require '../models'

logger = require('log4js').getLogger()
logger.setLevel "INFO"

fixture = 
  code: 'deadbeef'
  user: 'unittest-user'
  second_user: 'another_unittest-user'
  lines: ['first line', 'second line', 'final line']

dropBatch = 
  "Drop collection":
    topic: ->
      collection = model_factory.create_collab_docs()
      collection.drop()
      return collection
    "and we try count present documents":
      topic: (collection) ->
        collection.find({}).count(@callback)
        return
      "we have successfully dropped the collection": (err, val) ->
        assert.equal val, 0

models_suite = vows.describe('Creating the data layer')
.addBatch(dropBatch)
.addBatch
  # vows to handle lockers
  "Given we can connect to the database":
    topic: -> 
      @callback null, model_factory.create_collab_docs()
      return

    "we should have a collection object": (err, collab_docs) ->
      assert.isObject collab_docs

    "and we've attempted to set a locker":
      topic: (collab_docs) ->
        collab_docs.set_locker fixture.code, fixture.user
        return collab_docs

      "and that we can retrieve said locker":
        topic: (collab_docs) ->
          collab_docs.get_locker fixture.code, @callback
          return

        "vow that the locker set equals the locker got": (err, val) ->
          assert.isNull err
          assert.equal val.locker, fixture.user
          return
.addBatch # vows to handle line insertions
  "Given we can connect to the database":
    topic: -> 
      @callback null, model_factory.create_collab_docs()
      return

    "and that we've set lines":
      topic: (collab_docs) ->
        collab_docs.set_lines fixture.code, fixture.lines, @callback
        return

      "vow that the operation doesn't return an error": (err, val)->
        assert.isNull err

      "vow that the operation returns the right code": (err, val)->
        assert.equal val.code, fixture.code

      "vow that the operation returns the right lines": (err, val)->
        assert.isArray val.lines
        assert.deepEqual val.lines, fixture.lines
.addBatch # vows to handle user management
  "Given we can connect to the database":
    topic: -> 
      @callback null, model_factory.create_collab_docs()
      return
    "and we try to retrieve users":
      topic: (collection) ->
        collection.get_users fixture.code, @callback
        return
      "vow that there are no users": (err, val) ->
        assert.isUndefined val.users

    "we add a user and check return value":
      topic: (collection) ->
        collection.add_user fixture.code, fixture.user, @callback
        return
      "vow that the user is present": (err, val) ->
        assert.isNull err
        assert.include val.users, fixture.user
        assert.length val.users, 1
    "we add a user":
      topic: (collection) ->
        collection.add_user fixture.code, fixture.second_user
        return collection
      "vow that we can retrieve it via db": (err, collection) ->
        assert.isNull err
        collection.get_users fixture.code, (err, val) ->
          assert.isNull err
          assert.include val.users, fixture.second_user

.addBatch dropBatch

models_suite.export(module)
