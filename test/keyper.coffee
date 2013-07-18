should = require 'should'
Keyper = require "../lib/keyper"


describe "Keyper", ->
  describe "Constructor", ->
    it "should initialize the internal data object", (done) ->
      keyper = new Keyper
      should.exist keyper._data
      done()

  describe "setValue", ->
    beforeEach (done) ->
      @keyper = new Keyper
      done()

    it "should set the key with the passed value", (done) ->
      @keyper.setValue 'someKey', 'someVal'
      @keyper.getValue('someKey').should.eql 'someVal'
      done()

    it "should overwrite the existing value with the new value", (done) ->
      @keyper.setValue 'someKey', 'someVal'
      @keyper.setValue 'someKey', 'someOtherVal'
      @keyper.getValue('someKey').should.eql 'someOtherVal'
      done()

  describe "getValue", ->
    beforeEach (done) ->
      @keyper = new Keyper
      done()    

    it "should return the specified value", (done) ->
      @keyper.setValue 'someKey', 'someVal'
      @keyper.getValue('someKey').should.eql 'someVal'
      done()  

    it "should return null if the key doesn't exist", (done) ->
      should.not.exist @keyper.getValue('someKey')
      done()

  describe "deleteValue", ->
    beforeEach (done) ->
      @keyper = new Keyper
      done()    

    it "should delete the specified value", (done) ->
      @keyper.setValue 'someKey', 'someVal'
      @keyper.getValue('someKey').should.eql 'someVal'
      @keyper.deleteValue('someKey')
      should.not.exist @keyper.data()['someKey']
      done()  

  describe "data", ->
    it "should return the data hash", (done) ->
      @keyper = new Keyper
      @keyper.setValue 'someKey', 'someVal'
      @keyper.data().should.eql @keyper._data
      @keyper.data()['someKey'].should.eql 'someVal'
      done()    

  describe "increment", ->
    beforeEach (done) ->
      @keyper = new Keyper
      done() 

    it "should increment the value to 1 if not set", (done) ->
      @keyper.increment "someKey"
      @keyper.getValue("someKey").should.eql 1
      done()

    it "should increment the value if it exists", (done) ->
      @keyper.setValue 'someKey', 2
      @keyper.increment "someKey"
      @keyper.getValue("someKey").should.eql 3
      done()

    it "should do nothing if the value isn't a number", (done) ->
      @keyper.setValue 'someKey', "2"
      @keyper.increment "someKey"
      @keyper.getValue("someKey").should.eql "2"
      done()

  describe "decrement", ->
    beforeEach (done) ->
      @keyper = new Keyper
      done() 

    it "should decrement the value to -1 if not set", (done) ->
      @keyper.decrement "someKey"
      @keyper.getValue("someKey").should.eql -1
      done()

    it "should decrement the value if it exists", (done) ->
      @keyper.setValue 'someKey', 2
      @keyper.decrement "someKey"
      @keyper.getValue("someKey").should.eql 1
      done()

    it "should do nothing if the value isn't a number", (done) ->
      @keyper.setValue 'someKey', "2"
      @keyper.decrement "someKey"
      @keyper.getValue("someKey").should.eql "2"
      done()

  describe "addValue", ->
    beforeEach (done) ->
      @keyper = new Keyper
      done() 

    it "should add the value to 0 if not set", (done) ->
      @keyper.addValue "someKey", 4
      @keyper.getValue("someKey").should.eql 4
      done()

    it "should add the value to the value if it exists", (done) ->
      @keyper.setValue 'someKey', 2
      @keyper.addValue "someKey", 4
      @keyper.getValue("someKey").should.eql 6
      done()

    it "should do nothing if the value isn't a number", (done) ->
      @keyper.setValue 'someKey', "2"
      @keyper.addValue "someKey", 4
      @keyper.getValue("someKey").should.eql "2"
      done()

  describe "subtractValue", ->
    beforeEach (done) ->
      @keyper = new Keyper
      done() 

    it "should subtract the value to 0 if not set", (done) ->
      @keyper.subtractValue "someKey", 4
      @keyper.getValue("someKey").should.eql -4
      done()

    it "should subtract the value to the value if it exists", (done) ->
      @keyper.setValue 'someKey', 2
      @keyper.subtractValue "someKey", 2
      @keyper.getValue("someKey").should.eql 0
      done()

    it "should do nothing if the value isn't a number", (done) ->
      @keyper.setValue 'someKey', "2"
      @keyper.subtractValue "someKey", 4
      @keyper.getValue("someKey").should.eql "2"
      done()      
