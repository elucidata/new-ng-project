class AppManager extends App.Service
  @inject
    log: ['Logger', this]

  initialize: ->
    @log "READY"
