(chai           = require 'chai').should()
{ArrayCollection} = require '../src/js-arraycollection.coffee'
jsonData        = require './data.json'
server          = true

describe 'ArrayCollection Tests', ->
  it 'should exist', =>
    (ArrayCollection).should.be.a 'function'
  it 'should instantiate with a passed in data set', =>
    (@collection = new ArrayCollection jsonData).length().should.equal 7
  it 'should allow items to be added at a given index', (done)=>
    @collection.on 'collectionChanged', (data)=>
      done() if data.added? and data.added.length == 2
    @collection.addAllAt([{name:"newObject", value:"A New Object"},{name:"anotherObject", value:"Another New Object"}],1).length().should.equal 9
  it 'should notify when collection item proerties have changed', (done)=>
    @collection.on 'collectionChanged', (data)=>
      done() if data.update[0].item == @collection.getItemAt(2) and data.update[0].oldValue == 'Another New Object' and data.update[0].newValue == 'A New Value'
    @collection.getItemAt(2).value = "A New Value"
 