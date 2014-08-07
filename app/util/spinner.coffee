#
# TODO: Update UI for new UI framework
#
class Spinner extends App.Service
  @inject
    ionicLoading: '$ionicLoading'
    timeout: '$timeout'

  initialize: ->
    @_count= 0
    @_isVisible= no

  show: (msg, icon)->
    @_count += 1
    @_toggleLoader msg, icon unless @timer?
    this

  hide: ->
    @_count= Math.max @_count - 1, 0
    @timeout.cancel @timer if @timer?
    @timer= @timeout @_toggleLoader, 50
    this

  _toggleLoader: (label='One moment...', icon="ion-ios7-reloading")=>
    @_isVisible= if @_count is 0
      @ionicLoading.hide()
      no

    else if @_count is 1 and not @_isVisible
      @ionicLoading.show template:"<i class='icon #{ icon }'></i> #{ label }"
      yes

    else
      yes

    @timeout.cancel @timer if @timer?
    @timer= null
