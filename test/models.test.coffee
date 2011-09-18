assert = require 'assert'
model_factory = require '../models'
collab_docs = model_factory.create_collab_docs()

test_code = 'deadbeef'
test_user = 'unittest-user'

exports['test the ability to set and get a locker'] = (beforeExit) ->
  collab_docs.set_locker test_code, test_user

  callbacks_called = 0

  collab_docs.get_locker test_code, (err, value) ->
    console.log 'in callback with value: ' + value.locker
    callbacks_called++
    assert.equal value.locker, test_user

  beforeExit ->
    console.log 'executing before_exit'
    assert.equal 1, callbacks_called

  # This doesn't work in mongolian and it really needs to. 
  # Stalls unit tests.
  # model_factory.close()
