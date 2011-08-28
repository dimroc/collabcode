@include = ->
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

  @collab_docs.set = (code, lines, callback) =>
    @collab_docs.findAndModify({
      new: true,
      upsert: true,
      query: { code: code },
      update: { code: code, lines: lines }
    }, callback)

  def mongodb: @db
  def collab_docs: @collab_docs
