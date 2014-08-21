
class @App extends Ng.Module
  @inject 'ngAnimate', 'ui.router', 'ui.bootstrap', 'ngPrettyJson', 'ngSanitize', 'ngActivityIndicator'

  @config ($httpProvider, $urlRouterProvider)->
    # Enable cross domain calls
    $httpProvider.defaults.useXDomain= yes
    $urlRouterProvider.otherwise '/'

  @run ()->
    console.debug "My.Project - Start"
