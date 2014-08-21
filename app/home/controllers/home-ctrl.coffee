class HomeController extends App.Controller
  @inject
    log: ['Logger', this]

  # ROUTES/STATES
  @config ($stateProvider)->
    $stateProvider
      .state 'home',
        url: '/'
        templateUrl: 'home/templates/home.html'
        controller: 'HomeController as home'

  initialize: ->
    @log "init!"
