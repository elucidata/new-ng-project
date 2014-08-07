
class Delay extends Ng.Factory
  @registerAs: 'delay'
  @inject
    timeout: '$timeout'

  initialize: ->
    _timeout= @timeout
    (amount, callback)->
      _timeout callback, amount


@delay= (amount, callback)->
  setTimeout callback, amount
