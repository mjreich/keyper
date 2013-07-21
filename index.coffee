express = require 'express'
_ = require 'underscore'

Keyper = require "./lib/keyper"

port = parseInt(process.env.PORT) || 8080

fs = require 'fs'
config = JSON.parse fs.readFileSync("./config.json").toString()

app = express()

Persister = require './lib/persister'

persister = new Persister config

ghClient = null

collections = {}
dirty = {}
newCollection = false

ensureCollection = (collection) ->
  console.log 'setting new collection = '+!collections[collection]?
  newCollection = !collections[collection]? unless newCollection is true
  collections[collection] ||= new Keyper
  return collections[collection]

setDirty = (collection) ->
  dirty[collection] = true
  if config and config.persistance and config.persistance is 'onchange'
    backup()

setBackup = () ->
  console.log 'starting backup'
  return if not config or not config.persistance?
  interval = switch config.persistance 
    when 'hourly' then 3600000
    when 'daily' then 86400000
    when 'monthly' then 2592000000
    else
      config.persistance    
  console.log interval
  return unless _.isNumber(interval)
  setInterval backup, interval

backup = () ->
  console.log 'backing up'
  index = {collections: []}
  for collectionName, collection of collections
    index.collections.push collectionName
    console.log "dirty = "+dirty[collectionName]
    continue unless dirty[collectionName]
    data = collection.data()
    saveFile collectionName, "Keyper backup at "+new Date().toString(), JSON.stringify(data, null, 4)
  console.log "newCollection = "+newCollection
  if newCollection
    console.log 'saving index'
    console.log index
    newCollection = false
    persister.saveFile "collections.json", "Keyper index backup at "+new Date().toString(), JSON.stringify(index, null, 4)  

saveFile = (collectionName, message, content) ->
  console.log "backing up "+collectionName
  console.log content
  persister.saveFile collectionName+".json", message, content, (err) ->
    console.log err if err
    dirty[collectionName] = false

startup = () ->
  console.log 'getting data from github'
  persister.getFile "collections.json", (err, content) ->
    return if err
    try
      index = JSON.parse content
    catch e
      return
    return unless index.collections  
    for collection in index.collections
      loadCollection collection

loadCollection = (collection) ->
  persister.getFile collection+".json", (err, file) ->
    return if err
    try 
      data = JSON.parse(file)
    catch e
      data = {}
    collections[collection] = new Keyper data

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


app.all "/*", (req, res, next) ->
  res.header "Access-Control-Allow-Origin", "*"
  res.header "Access-Control-Allow-Headers", "X-Requested-With"
  next()

app.get "/backup", (req, res) ->
  backup()
  res.send 200


app.post "/:collection/:key/push", (req, res) ->
  console.log 'push called'
  collection = req.param 'collection'
  key = req.param 'key'
  console.log key
  return res.send 400 unless collection and key
  try 
    value = JSON.parse req.body
  catch e
    value = req.body
  console.log value
  keyper = ensureCollection(collection)
  keyper.push key, value
  setDirty(collection)
  res.send 200

app.post "/:collection/:key/increment", (req, res) ->
  console.log 'push called'
  collection = req.param 'collection'
  key = req.param 'key'
  console.log key
  return res.send 400 unless collection and key
  keyper = ensureCollection(collection)
  keyper.increment key
  setDirty(collection)
  res.send 200

app.post "/:collection/:key", (req, res) ->
  collection = req.param 'collection'
  key = req.param 'key'
  return res.send 400 unless collection and key
  try 
    value = JSON.parse req.body
  catch e
    value = req.body
  keyper = ensureCollection(collection)
  keyper.setValue key, value
  setDirty(collection)
  res.send 200

app.get "/:collection/:key", (req, res) ->
  collection = req.param 'collection'
  key = req.param 'key'
  keyper = collections[collection]
  return res.send 400 unless collection and key
  return res.send 404 if not keyper or not keyper.keyExists(key)
  value = keyper.getValue(key)
  return res.send value

app.delete "/:collection/:key", (req, res) ->
  collection = req.param 'collection'
  key = req.param 'key'
  return res.send 400 unless collection and key
  value = req.body
  keyper = ensureCollection(collection)
  keyper.deleteValue key
  setDirty(collection)
  res.send 200  

app.get "/:collection", (req, res) ->
  collection = req.param 'collection'
  return res.send 404 unless collections[collection] 
  return res.send collections[collection].data()

app.listen port
console.log 'Keyper started on port '+port

setBackup()

startup()

module.exports = 
  app: app
  backup: backup