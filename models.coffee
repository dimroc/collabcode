collab_docs_factory = (is_logging_to_console) ->
  logger = require('log4js').getLogger()
  mongolian = require 'mongolian'

  hostname = process.env.MONGO_HOST || 'localhost'
  dbname = process.env.MONGO_DB || 'test'
  user = process.env.MONGO_USER
  password = process.env.MONGO_PASS

  if user?
    connection_string = "#{user}:#{password}@#{hostname}/#{dbname}"
  else
    connection_string = "#{hostname}/#{dbname}"

  logger.debug 'connecting to: ' + connection_string
  noop_logger =
    log:
      debug: ->
      info: ->
      warn: ->
      error: ->
  log4js2mongolian =
    log: logger

  if is_logging_to_console? && is_logging_to_console
    @db = new mongolian connection_string, log4js2mongolian 
  else
    @db = new mongolian connection_string, noop_logger

  @collab_docs = @db.collection "collabs"

  @collab_docs.get = (code, callback) =>
    @collab_docs.findOne({ code: code }, callback)

  @collab_docs.get_lines = (code, callback) =>
    @collab_docs.findOne({ code: code }, {code:true, lines: true}, callback)

  @collab_docs.set_lines = (code, lines, callback) =>
    callback ?= ->
    @collab_docs.findAndModify({
      new: true,
      upsert: true,
      query: { code: code },
      update: { code: code, lines: lines }
    }, callback)

  @collab_docs.get_users = (code, callback) =>
    @collab_docs.findOne({ code: code}, {users:true}, callback)

  @collab_docs.add_user = (code, user, callback) =>
    callback ?= ->
    @collab_docs.findAndModify({
      new: true,
      upsert: true,
      query: { code: code },
      update: { $push: { users: user } }
    }, callback)

  @collab_docs.remove_user = (code, user, callback) =>
    callback ?= ->
    @collab_docs.findAndModify({
      query: {code: code},
      update: { $pull: { users: user }}
    }, callback)

  @collab_docs.set_locker = (code, user) =>
    logger.debug "Setting locker for room #{code} to user #{user}"
    @collab_docs.update( { code: code }, {$set: { locker: user}}, true, false )

  @collab_docs.get_locker = (code, callback) =>
    logger.debug "Attempting to retrieve locker for room #{code}"
    @collab_docs.findOne({code: code}, callback)

  logger.debug 'returning collab collection'
  return @collab_docs

@include = ->
  # The difficulty in containing the 'this' pointer and knowing when or what dynamic code
  # has been loaded has led to this weird model below where I'm literally importing myself
  # to call the factory function. 
  # Investigate taking a class based solution to this so I can encapsulate code in one class
  # more elegantly.
  model_factory = require 'models'
  @collab_docs = model_factory.create_collab_docs()
  def collab_docs: @collab_docs

close = ->
  logger = require('log4js').getLogger()
  logger.debug 'Closing db connection.'
  # TODO:this doesn't work! Waiting for update from library.
  @db.close()

# allow hook for unit tests to access model layer via 'require'
exports.create_collab_docs = collab_docs_factory
exports.close = close

