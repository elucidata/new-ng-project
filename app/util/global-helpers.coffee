helpers=

  shortDate: (date)->
    @formatDate date, 'l'

  longDate: (date)->
    @formatDate date, 'LL'

  # Requires moment library: bower install moment --save
  formatDate: (date, format='LL')->
    moment(date).format(format)

  appInjector: (key)->
    inj= angular.element(document).injector()
    if key?
      inj.get key #.merge({ jobid:41, newcustomer:true })
    else
      inj

  defaults: (target, source)->
    Object.merge target, source, true, false


  # Requires marked library: bower install marked --save
  markdown: (args...)->
    if args.length is 1
      opts= {}
      block= args[0]
    else
      [opts, block]= args
    helpers.defaults opts,
      gfm: yes
      smartypants: yes
      smartLists: yes
      tables: yes
    @safe marked block(), opts



@applyHelpersTo= (target)->
  helpers.defaults(target, helpers)

applyHelpersTo this
