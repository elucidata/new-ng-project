class MainController extends App.Controller
  @inject
    log: ['Logger', this]
    scope: '$scope'
    delay: 'delay'

  initialize: ->
    @log "Init!"
    @scope.alerts= []

    @delay 1000, => @addAlert 'The app is on fire!', 'danger'
    @delay 1500, => @addAlert "Oh, no. Nevermind, everything is fine.", 'info'
    @delay 2000, => @addAlert "And look, now there's navigation items."

  closeAlert: (idx)->
    @scope.alerts.removeAt idx

  addAlert: (msg, type='warning')->
    msg or="I'm new here. What do you <i>think</i>?"
    @scope.alerts.push { type, msg }
