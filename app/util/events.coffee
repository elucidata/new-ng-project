class Events extends Ng.Service
  @inject
    log: ['Logger', this]
    root: '$rootScope'

  _known_handlers= []

  initialize: ->
    @root.$on '$destroy', =>
      for handlers in _known_handlers
         try handlers.dereg?()
      _known_handlers= []

  each: (map)->
    for event, handler of map
      @on event, handler
    this

  on: (event, handler)->
    throw new Error "Event handler can only handle a single event!" if handler.dereg?
    handler.dereg= @root.$on event, handler
    _known_handlers.push handler
    handler.dereg

  once: (event, handler)->
    dereg= @root.$on event, ->
      try
        handler(arguments...)
      finally
        dereg()

  off: (handler)->
    handler.dereg?()
    this

  trigger: (event, data...)->
    @root.$emit event, data...
    this
  fire: @::trigger
  emit: @::trigger

  globalTrigger: (event, data...)->
    @root.$broadcast event, data...
    this
  broadcast: @::globalTrigger

  scoped: (scope)->
    new EventCollectorImpl scope, this
  boundTo: @::scoped


class EventCollector extends Ng.Factory
  @inject()
  initialize: -> EventCollectorImpl

class EventCollectorImpl

  constructor: (scope, @appEvents)->
    @list= []
    if scope?
      scope.$on '$destroy', @clear

  add: (stop)=>
    @list.push stop
    stop

  clear: =>
    stop?() for stop in @list
    this

  on: (event, fn)->
    if arguments.length is 1 and typeof event is 'object'
      for ev, handler of map
        @add @appEvents.on ev, handler
    else
      @add @appEvents.on event, fn

  once: (event, fn)->
    @add @appEvents.once event, fn
