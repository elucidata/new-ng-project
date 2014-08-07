
class NavController extends App.Controller
  @inject
    log: ['Logger', this]
    delay: 'delay'

  initialize: ->
    @log 'init'
    @showNav= no

    @delay 2000, =>
      @log "Show nav!"
      @showNav= yes
