js-arraycollection
==================

A Javascript Implementation of Array Collection (using UndercoreJS)

[![Build Status](https://travis-ci.org/vancarney/js-arraycollection.png)](https://travis-ci.org/vancarney/js-arraycollection)
[![NPM Version](http://img.shields.io/npm/v/js-arraycollection.svg)](https://www.npmjs.org/package/js-arraycollection)

Installation
-----------

npm:
```
npm install js-arraycollection
```

bower
```
bower install js-arraycollection
```


Usage
-----------


*coffeescript* example:

```
(inst = new ArrayCollection [{value:'foo'}, {value:'bar'}]
).on 'collectionChanged', (data)->
  data.keys().forEach (key, val)->
  	console.log "#{key}:#{JSON.stringify val}"
inst.addItem value:'baz'
inst.getItemAt(0).value = 'huzzah'
inst.removeItemAt inst.length() - 1
```

*javascript* example:

```
var inst;
(inst = new ArrayCollection( [{value:'foo'}, {value:'bar'}] )
).on( 'collectionChanged', function (data) {
  data.keys().forEach( function (key, val) {
  	console.log(""+key+": "+JSON.stringify( val ) );
  });
});
inst.addItem( {value:'baz'} );
inst.getItemAt(0).value = 'huzzah';
inst.removeItemAt( inst.length() - 1 );
``` 

Events
-----------

#### Added
Triggered when an item is added to the collection

#### Updated
Triggered when an item's properties have been updated

#### Removed
Triggered when an item has been removed

#### Replaced
Triggered when an item has been replaced with another

#### Reset
Triggered when the collection has been reset to it's default state


Methods
-----------

#### length()
Returns the current length of the Array

#### setSource(list)
Sets the source array triggering an `added` event

#### clearSource()
Resets the source array resulting in a `reset` event

#### addAll(list)
Adds all passed list members to source triggering an `added` event

#### addItem(object)
Add an individual item to the source triggering an `added` event

#### addItemAt(object, offset)
Adds an individual item to the source at given offset triggering an `added` event

#### contains(object)
Checks if source contains specified item

#### getItemAt( index )
Get item at given index

#### getItemIndex( object )
Get index of given item in source

#### removeAll()
Removes all members in source triggering a `reset` event

#### removeItemAt( index )
Removes item at given index triggering `remove` event

#### setItemAt( item, index)
Replaces item at index with given item triggering `replaced` event
