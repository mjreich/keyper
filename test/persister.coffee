fs = require 'fs'
config = JSON.parse fs.readFileSync("./test/config.json").toString()
should = require 'should'

Persister = require "../lib/persister"

file_data = "{'test': 'value'}"
new_file_data = "{'test': 'newValue'}"

describe "Persister", ->
  describe "constructor", ->
    beforeEach (done) ->
      @persister = new Persister(config)
      done()

    it "should save the config", (done) ->
      should.exist @persister._config
      @persister._config.should.eql config
      done()

    it "should throw an error if the github key doesn't exist", (done) ->
      (() ->
        temp = new Persister {}
      ).should.throw()
      done()

    it "should throw an error if the github apikey doesn't exist", (done) ->
      (() ->
        temp = new Persister {github: {}}
      ).should.throw(/apikey/)
      done()  

    it "should throw an error if the github owner doesn't exist", (done) ->
      (() ->
        temp = new Persister {github: {apikey: ""}}
      ).should.throw(/owner/)
      done()   

    it "should throw an error if the github repo doesn't exist", (done) ->
      (() ->
        temp = new Persister {github: {apikey: "", owner: ""}}
      ).should.throw(/repo/)
      done()       

  describe "createFile", ->
    it "should create the file with the given filename and contents", (done) ->
      @persister.createFile "collection.json", "test create", file_data, (err, res) ->
        should.not.exist err
        done()

  describe "getFile", ->
    it "should return the contents if the file exists", (done) ->
      @persister.getFile 'collection.json', (err, body) ->
        should.not.exist err
        body.should.eql file_data
        done()

    it "should return an error if the file doesn't exist", (done) ->
      @persister.getFile 'fake-collection.json', (err, body) ->
        should.exist err
        done()

  describe "updateFile", ->
    it "should update the file with the new contents", (done) ->
      @persister.updateFile "collection.json", "test update", new_file_data, (err, res) =>
        should.not.exist err
        @persister.getFile 'collection.json', (err, body) ->
          should.not.exist err
          body.should.eql new_file_data
          done()

  describe "fileExists", ->
    it "should return false if the file doesn't exist" ,(done) ->
      @persister.fileExists "fakefile.json", (exists) ->
        exists.should.eql false
        done()

    it "should return true if the file doesn't exist" ,(done) ->
      @persister.fileExists "collection.json", (exists) ->
        exists.should.eql true
        done()

  describe "deleteFile", ->
    it "should remove the file with the given filename", (done) ->
      @persister.deleteFile "collection.json", "test remove", (err, res) ->
        should.not.exist err
        done()
