(chai             = require 'chai').should()
{ArrayCollection} = require '../src/js-arraycollection'
jsonData          = require './data.json'

describe 'ArrayCollection Tests', ->
  it 'should instantiate with a passed in data set', =>
    (@collection = new ArrayCollection jsonData).length().should.equal 7
  it 'should get an item', =>
    (@item = @collection.getItemAt(2)).name.should.equal 'object3'
  it 'should get an item\'s index', =>
    @collection.getItemIndex(@item).should.equal 2
  it 'should notify when collection items have been added', (done)=>
    collection = new ArrayCollection jsonData
    collection.on 'collectionChanged', (data)=>
      done() if data.added.length
    collection.addItem {value:'foo'}
  it 'should allow items to be added at a given index', (done)=>
    @collection.on 'collectionChanged', (data)=>
      done() if data.added? and data.added.length == 2
    @collection.addAllAt([{name:"newObject", value:"A New Object"},{name:"anotherObject", value:"Another New Object"}],1).length().should.equal 9
  it 'should notify when collection item properties have changed', (done)=>
    @collection.on 'collectionChanged', (data)=>
      done() if data.update[0].item == @collection.getItemAt(2) and data.update[0].oldValue == 'Another New Object' and data.update[0].newValue == 'A New Value'
    @collection.getItemAt(2).value = "A New Value"
  it 'should notify when collection items have been removed', (done)=>
    collection = new ArrayCollection jsonData
    collection.on 'collectionChanged', (data)=>
      done() if data.removed.length
    collection.removeItemAt 3
  it 'should notify when the collection has been reset', (done)=>
    collection = new ArrayCollection jsonData
    collection.on 'collectionChanged', (data)=>
      done() if data.reset
    collection.clearSource()
  it 'should notify when the collection has been reset by removeAll', (done)=>
    collection = new ArrayCollection jsonData
    collection.on 'collectionChanged', (data)=>
      done() if data.reset
    collection.removeAll()
  it 'should notify when an item has been replaced', (done)=>
    collection = new ArrayCollection jsonData
    collection.on 'collectionChanged', (data)=>
      done() if data.replaced
    collection.setItemAt {value:'huzzah'}, 3
