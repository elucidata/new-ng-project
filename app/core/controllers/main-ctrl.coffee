class MainController extends App.Controller
  @inject
    log: ['Logger', this]
    scope: '$scope'
    delay: 'delay'
    spinner: '$activityIndicator'

  initialize: ->
    @log "Init!"
    @scope.alerts= []

    @spinner.startAnimating()

    @delay 1000, => @addAlert 'The app is on fire!', 'danger'
    @delay 1500, => @addAlert "Oh, no. Nevermind, everything is fine.", 'info'
    @delay 2000, => @addAlert "And look, now there's navigation items."

    @delay 2500, => @spinner.stopAnimating()

  closeAlert: (idx)->
    @scope.alerts.removeAt idx

  addAlert: (msg, type='warning')->
    msg or="I'm new here. What do you <i>think</i>?"
    @scope.alerts.push { type, msg }

  showSpinner: (e)->
    # @log 'E', e
    @spinner.startAnimating()
    @delay 1500, => @spinner.stopAnimating()
