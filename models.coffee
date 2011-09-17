@include = ->
  def mongodb: @db
  def collab_docs: @collab_docs

collab_docs_factory = ->
  mongolian = require 'mongolian'

  hostname = process.env.MONGO_HOST || 'localhost'
  dbname = process.env.MONGO_DB || 'test'
  user = process.env.MONGO_USER
  password = process.env.MONGO_PASS

  if user?
    connection_string = "#{user}:#{password}@#{hostname}/#{dbname}"
  else
    connection_string = "#{hostname}/#{dbname}"

  console.log connection_string
  @db = new mongolian connection_string
  console.log 'finished connecting'

  @collab_docs = @db.collection "collabs"

  @collab_docs.get = (code, callback) =>
    @collab_docs.findOne({ code: code }, callback)

  @collab_docs.get_lines = (code, callback) =>
    @collab_docs.findOne({ code: code }, {code:true, lines: true}, callback)

  @collab_docs.set_lines = (code, lines, callback) =>
    @collab_docs.findAndModify({
      new: true,
      upsert: true,
      query: { code: code },
      update: { code: code, lines: lines }
    }, callback)

  @collab_docs.get_users = (code, callback) =>
    @collab_docs.findOne({ code: code}, {users:true}, callback)

  @collab_docs.add_user = (code, user, callback) =>
    @collab_docs.findAndModify({
      new: true,
      upsert: true,
      query: { code: code },
      update: { $push: { users: user } }
      , callback })

  @collab_docs.remove_user = (code, user, callback) =>
    @collab_docs.findAndModify({
      query: {code: code},
      update: { $pull: { users: user } },
      callback
    })

  @collab_docs.set_locker = (code, user) =>
    @collab_docs.update( { code: code }, $set: { locker: locker}, true, false )

  @collab_docs.get_locker = (code, callback) =>
    @collab_docs.findOne({code: code}, {locker: true}, callback)

  return @collab_docs

# allow hook for unit tests to access model layer via 'require'
exports.create_collab_docs = collab_docs_factory
