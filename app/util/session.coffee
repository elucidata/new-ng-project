class NgSession extends Ng.Factory
  @registerAs: 'Session'
  @inject()

  initialize: ->
    -> new Session arguments...

class Session

  constructor: (@prefix='session', storage='local')->
    # alert "No native JSON support!" unless window.JSON
    @_type= storage
    @_store=
      if storage is 'local' and window.localStorage
        # console?.log "Using LocalStorage", window.localStorage
        window.localStorage
      else if storage is 'session' and window.sessionStorage
        window.sessionStorage
      else
        # console?.log "Using MemoryStorage"
        new MemoryStorage

  set: (name, value) ->
    attrs=
      if arguments.length is 2
        obj={}
        obj[name]= value
        # console.log 'name,value', name, value, obj
        obj
      else
        name
    for own key,val of attrs
      # console.log 'key,val', key, val
      @_store.setItem @_keyName(key), JSON.stringify(val)
    attrs

  get: (name, defaultValue) ->
    src= @_store.getItem(@_keyName(name))
    if src?
      JSON.parse src
    else
      defaultValue or null

  remove: (name) ->
    @_store.removeItem(@_keyName(name))

  clear: ->
    if window.localStorage
      for i in [0..@_store.length]
        key= @_store.key i
        if key? and key.startsWith @prefix
          @_store.removeItem key
    else
      @_store.clear()

  _keyName: (key)->
    "#{@prefix}-#{key}"


class MemoryStorage
  constructor: ->
    @clear()

  setItem: (name, value)->
    @_cache[name]= value

  getItem: (name) ->
    @_cache[name]

  removeItem: (name) -> # TODO: Validate signature
    delete @_cache[name]

  clear: ->
    @_cache= {}
