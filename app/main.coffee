
class @App extends Ng.Module
  @inject 'ngAnimate', 'ui.router', 'ui.bootstrap', 'ngPrettyJson', 'ngSanitize'

  @config ($httpProvider)->
    # Enable cross domain calls
    $httpProvider.defaults.useXDomain= yes

  @run ()->
    console.debug "My.Project - Start"
