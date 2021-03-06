supertest = require('supertest')
should = require 'should'
index = require("../index")

server = index.app

agent = supertest(server)

describe "Keyper API", ->

  describe "POST /collection/value", ->
    before ->
      @collection = 'someCollection'
      @key = 'someKey'
      @jsonKey = "jsonKey"
      @value = 'someValue'
      @jsonValue = {subkey: "subvalue"}

    it "should set the correct value", (done) ->
      agent
      .post("/#{@collection}/#{@key}")
      .send(@value)
      .end (err, res) ->
        console.log err if err
        console.log res.text if res.status is 500
        res.status.should.eql 200
        done(err)

  describe "GET /collection/value", ->
    it "should return the correct value", (done) ->
      agent
      .get("/#{@collection}/#{@key}")
      .end (err, res) =>
        res.text.should.eql @value
        done()

    it "should return 404 if the key doesn't exist", (done) ->
      agent
      .get("/#{@collection}/fakeKey")
      .end (err, res) ->
        res.status.should.eql 404
        done()    

  describe "GET /collection", ->
    it "should return the complete obj", (done) ->
      agent
      .get("/#{@collection}")
      .end (err, res) =>
        obj = JSON.parse res.text
        should.exist obj[@key]      
        obj[@key].should.eql @value
        done()

    it "should return 404 if the collection doesn't exist", (done) ->
      agent
      .get("/doesntExist")
      .end (err, res) ->
        res.status.should.eql 404
        done()    

  describe "DELETE /collection/key", ->
    it "should delete the value", (done) ->
      agent
      .del("/#{@collection}/#{@key}")
      .end (err, res) =>
        res.status.should.eql 200
        agent
        .get("/#{@collection}")
        .end (err, res) =>
          obj = JSON.parse res.text
          should.not.exist obj[@key] 
          done()

  describe "POST JSON support", ->
    it "should set the value as json if passed a valid json object", (done) ->
      agent
      .post("/#{@collection}/#{@jsonKey}")
      .send(@jsonValue)
      .end (err, res) =>
        console.log err if err
        console.log res.text if res.status is 500
        res.status.should.eql 200
        done(err) if err
        agent
        .get("/#{@collection}/#{@jsonKey}")
        .end (err, res) =>
          res.status.should.eql 200
          should.exist res.text
          try
            json = JSON.parse res.text
          catch e
            done(e)
          json.should.eql @jsonValue
          done(err)        
