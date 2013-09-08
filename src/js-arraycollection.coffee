#### A simple in-memory Object Store for protoyping
global = exports ? window
# include  Backbone and Underscore if we are in a Node App
if typeof exports != 'undefined'
  _ = require('underscore')
(->
  # restrict our code to use less dangerous functionality
  'use strict'
  wf = global.wf = {} if !global.wf
  # A partial port of Backbone.Events for event binding/triggering
  if !global.Events
    Events = global.Events =
      on: (name, callback, context)->
        return @ if  !eventsApi( @, 'on', name, [callback, context]) || !callback
        @_events || (@_events = {})
        events = @_events[name] || (@_events[name] = [])
        events.push callback: callback, context: context, ctx: context || @
        @
      off: (name, callback, context)->
        return @ if !@_events || !eventsApi(@, 'off', name, [callback, context])
        if (!name && !callback && !context)
          @_events = {};
          return @
        names = if name then [name] else _.keys @_events
        _.each names, (v,i)=>
          name = names[i];
          if (events = this._events[name]) 
            this._events[name] = retain = []
            if (callback || context)
              k = events.length
              _.each events, (v,j)=>
                retain.push ev if (callback && callback != (ev = events[j]).callback && callback != ev.callback._callback) || (context && context != ev.context)
            delete @_events[name] if !retain.length
        @
      trigger: (name)->
        return @ if !@_events
        args = [].slice.call arguments, 1
        return @ if !eventsApi @, 'trigger', name, args
        events    = @_events[name]
        allEvents = @_events.all
        triggerEvents events, args if events
        triggerEvents allEvents, arguments if allEvents
        @
    eventSplitter = /\s+/
    eventsApi = (obj, action, name, rest)->
      return true if !name
      if typeof name == 'object'
        _.each name, (v,key)=> obj[action].apply( obj, [key, name[key]].concat rest )
        return false
      if eventSplitter.test name
        names = name.split(eventSplitter);
        _.each names, (v,i)=>
          obj[action].apply(obj, [names[i]].concat(rest));
        return false;
      true
    triggerEvents = (events, args)->
      i = -1
      l = events.length
      a1 = args[0]
      a2 = args[1]
      a3 = args[2]
      switch (args.length)
        when 0
          while (++i < l) 
            (ev = events[i]).callback.call(ev.ctx) 
          return
        when 1
          while (++i < l) 
            (ev = events[i]).callback.call(ev.ctx, a1) 
          return
        when 2
          while (++i < l) 
            (ev = events[i]).callback.call(ev.ctx, a1, a2)
          return
        when 3
          while (++i < l) 
            (ev = events[i]).callback.call(ev.ctx, a1, a2, a3)
          return
        else
          while (++i < l) 
            (ev = events[i]).callback.apply(ev.ctx, args)
    Events.bind   = Events.on
    Events.unbind = Events.off
  class global.ArrayCollection
    __updated:false
    __list:[]
    __callbacks:[]
    __serial:''
    # converts hash in serialized arrays of key/val pairs
    __serialize:(o)->
      _.map o, (v,k)-> 
        _.map _.pairs(v), (v1,k1)-> v1.join ':'
    constructor : (source)->
      _.extend @, Events
      # setSource if list is passed
      @setSource source if source?
      # start watching for changes on source array
      setInterval (=>
        updates = []
        # quack pass on serilized versions
        if @__serial != (sList = @__serialize @__list)
          # loop through serial items if change is detected
          _.each @__serial, (v,k)=>
            # get the changed properties from serizlized item
            if (diff = _.difference v, sList[k]).length
              _.each diff, (dV,dK) =>
                # puch each updated property and it's item into an item Update object
                updates.push @itemUpdated @__list[k], (prop=dV.split ':')[0], prop[1], @__list[k][prop[0]]
          # dispatch update event with updated items
          @collectionChanged 'update', updates if updates.length
        # reset our serialized list
        @__serial   = @__serialize @__list
        # reset our updates list
        updates = []
      ), 200
    # returns collection length
    length : ->
      @__list.length
    # sets the source array resulting in an added event
    setSource : (source)->
      @addAll source if source?
    # resets the soruce array resulting ina reset event
    clearSource : ->
      @removeAll()
    # adds all passed lit members to source
    addAll : (list)->
      @addAllAt list, @__list.length
    # adds all passed list members to source starting at offset index
    addAllAt : (list, idx)->
      last = (l = _.clone @__list).splice idx, l.length
      cat = _.partial ((a2,a3,a1)-> _.compact [].concat a1,a2,a3), (added = _.clone list), last
      @__list = if l.length then cat l  else cat()
      @collectionChanged 'added', added
    # add an individual item to the source
    addItem : (itm)->
      @addItemAt itm, @__list.length
    # add an individual item to the source at offset
    addItemAt : (itm,idx)->
      @addAllAt itm, idx
    # check if source contains specified item
    contains : (itm)->
      _.contains @__list, itm
    # get item at given index
    getItemAt : (idx)->
      @__list[idx] || null
    # get items index
    getItemIndex : (itm)->
      @__list.indexOf itm
    # triggers a collection change -- don't call dirrectly
    collectionChanged : (operation, items) ->
      data = {}
      data[operation] = items
      @__updated = true
      @__serial = @__serialize @__list
      @trigger 'collectionChanged', data
    # item updated method -- don't call directly
    itemUpdated : (o,p,oV,nV) ->
      item:o
      prop:p
      oldValue:oV
      newValue:nV
    # remove all members in source resulting in reset event
    removeAll : ->
      l = @__list.splice 0, @__list.length
      @collectionChanged 'reset', l
    # remove item at index resulting in remove event
    removeItemAt : (idx)->
      @collectionChanged 'removed', (@__list.splice idx, 1) if @__list.length >= idx
    # replace item at index with given item resulting in replaced event
    setItemAt : (itm,idx)->
      r = null
      r = @__list.splice idx, 1 if @__list.length >= idx
      @__list.splice idx, 1, itm
      @collectionChanged 'replaced', r
).call @