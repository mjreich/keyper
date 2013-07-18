github = require 'octonode'

class Persister
  constructor: (@_config) ->
    throw new Error "Github config is required" unless @_config.github?
    throw new Error "Github apikey is required" unless @_config.github.apikey?
    throw new Error "Github owner is required" unless @_config.github.owner?
    throw new Error "Github repo is required" unless @_config.github.repo?
    @_repo = @_config.github.repo
    @_owner = @_config.github.owner
    @_initClient()

  saveData: (collectionName, data) ->
    if not @_client
      @_initClient()

  getFile: (filename, cb) ->
    @_client.get "/repos/#{@_owner}/#{@_repo}/contents/#{filename}", (err, status, body) =>
      file = if body and body.content
        new Buffer(body.content, 'base64').toString('ascii') 
      else
        null
      cb err, file, body if cb

  fileExists: (filename, cb) ->
    @getFile filename, (err, file) ->
      cb !err?

  createFile: (filename, message, content, cb) ->
    data = {}
    data.message = message
    data.content = new Buffer(content).toString('base64')
    @_client.put "/repos/#{@_owner}/#{@_repo}/contents/#{filename}", data, (err, status, body) =>
      cb err, body if cb

  deleteFile: (filename, message, cb) ->
    @getFile filename, (err, file, res) =>
      return cb err if err and cb
      data = {}
      data.message = message
      data.sha = res.sha
      @_client.del "/repos/#{@_owner}/#{@_repo}/contents/#{filename}", data, (err, status, body) => 
        cb err, body if cb

  _initClient: () ->
    @_client = github.client(@_config.github.apikey)

module.exports = Persister

