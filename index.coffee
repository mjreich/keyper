express = require 'express'

Keyper = require "./lib/keyper"

port = parseInt(process.env.PORT) || 8080

fs = require 'fs'
config = JSON.parse fs.readFileSync("./config.json").toString()

app = express()

ghClient = null

ensureCollection = (collection) ->
  collections[collection] ||= new Keyper
  return collections[collection]

backup = () ->
  return if not config or not config.persistence
  interval = switch config.persistance 
    when 'hourly' then 3600
    when 'daily' then 86400
    when 'monthly' then 2592000
    else
      config.persistance if _.isNumber(config.persistance)
      0
  setInterval () ->
    for collectionName, collection of collections
      data = collection.data()
      saveGitHubFile collectionName, data
  , interval    

saveGitHubFile = (collectionName, data) ->


app.use (req, res, next) ->
  req.body = req.body || {}
  req.setEncoding('utf8')
  buf = ''
  req.on 'data', (chunk) -> buf += chunk 
  req.on 'end', ->
    try 
      req.body = buf
      next()
    catch err
      err.body = buf
      next(err)

collections = {}

app.post "/:collection/:key", (req, res) ->
  collection = req.param 'collection'
  key = req.param 'key'
  return res.send 400 unless collection and key
  value = req.body
  keyper = ensureCollection(collection)
  keyper.setValue key, value
  res.send 200

app.get "/:collection/:key", (req, res) ->
  collection = req.param 'collection'
  key = req.param 'key'
  keyper = collections[collection]
  return res.send 400 unless collection and key
  return res.send 404 unless keyper
  value = keyper.getValue(key)
  return res.send 404 unless value
  return res.send value

app.delete "/:collection/:key", (req, res) ->
  collection = req.param 'collection'
  key = req.param 'key'
  return res.send 400 unless collection and key
  value = req.body
  keyper = ensureCollection(collection)
  keyper.deleteValue key
  res.send 200

app.get "/:collection", (req, res) ->
  collection = req.param 'collection'
  return res.send 404 unless collections[collection] 
  return res.send collections[collection].data()

app.listen port
console.log 'Keyper started on port '+port

backup()

module.exports = 
  app: app
  backup: backup
  saveGitHubFile: saveGitHubFile