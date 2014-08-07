class Errors extends Ng.Service
  @inject
    root: '$rootScope'

  catch: (message)=>
    (reason)=>
      @error message, reason

  warning: (message)=>
    @root.$broadcast 'flash.warning', message.message or message
  warn: @::warning

  notify: (message)=>
    # @root.$broadcast 'flash.info', message
    @root.$broadcast 'flash.error', message

  info: (message, ctx)->
    @root.$broadcast 'flash.info', message, ctx

  error: (message, reason)=>
    @root.addError? message:message, reason: reason

  show: @::error

  clear: =>
    @root.$broadcast 'flash.clear'

  @config ($provide)->
    $provide.decorator "$exceptionHandler", ($delegate, $injector)->
      (exception, cause)->
        $rootScope = $injector.get "$rootScope"
        $rootScope.addError? message:"Runtime Error: #{ exception.message or 'Unknown' }", reason:exception
        $delegate exception, cause

  @run ($rootScope)->
    $rootScope.errors= []
    $rootScope.addError= (err)->
      console.warn "ERROR DETECTED:", err
      msg= err.message or err or "An unknown error has occured."
      $rootScope.errors.push message:msg, reason:err

      unless msg.has "replaceChild"
        $rootScope.$broadcast 'flash.error', msg

      else
        console.error "IGNORING ERROR:", msg
