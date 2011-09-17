@model = require "../models"
@collab_docs = @model.create_collab_docs()

@test_code = 'deadbeef'
@test_user = 'jasmine-tester'

describe "server - models", ->
  it "makes testing JavaScript awesome!", ->
    expect(1==1).toEqual true

  it "confirms that we can set and get the locker", ->
    debugger
    runs ->
      debugger
      @collab_docs.set_locker test_code, test_user
    waits 500

    get_complete = false
    runs ->
      debugger
      @collab_docs.get_locker test_code, (arg) ->
        console.log arg
        debugger
        get_complete = true

    console.log 'waiting for async operation'
    waitsFor ->
      console.log 'waiting'
      get_complete
