
class Logger extends Ng.Factory

  @inject
    log: '$log'

  initialize: ->
    _log= @log
    (prefix)->
      logger= new LoggerImpl prefix, _log
      api= -> logger.debug arguments...
      Object.merge api, logger


class LoggerImpl
  log= null

  constructor: (prefix, logger=console)->
    @prefix= "#{ prefix.name or prefix.constructor?.name or prefix or '~' }:"
    if log isnt logger
      log= logger
      # log.info "Assigning log...", logger
  log: =>
    log.log @prefix, arguments...
  debug: =>
    log.debug @prefix, arguments...
  out: @::debug
  warn: =>
    log.warn @prefix, arguments...
  error: =>
    log.error @prefix, arguments...
