# Requires SugarJS...

@Ng=
  annotateDependencies: (Class, props={})->
    Class.$inject or= []
    Class.$injected or= []
    for name,deps of props
      deps= [ deps ].flatten()
      Class.$inject.push deps.shift()
      Class.$injected.push { name, params:deps }
    Class

  assignDependencies: (inst, injected)->
    if inst.constructor.$injected?
      for {name, params}, index in inst.constructor.$injected
        inst[ name ]=
          if params.length > 0
            injected[ index ]?.apply null, params
          else
            injected[ index ]
    inst

  getTransformedName: (Class, defaultTransform='classify')->
    return Class.registerAs if Class.registerAs?
    switch Class.nameTransform or defaultTransform
      when 'dasherize' then Class.name.dasherize()
      when 'camelize' then Class.name.camelize(false)
      when 'underscore' then Class.name.underscore()
      when 'classify' then Class.name.camelize()
      else Class.name

  getModule: (Class, autoCreate=yes)->
    try
      angular.module( Class.module )
    catch ex
      if autoCreate
        deps= Class.moduleDeps or []
        angular.module( Class.module, deps )
      else
        throw ex

class Ng.Base
  @module: 'app'
  @nameTransform: 'classify' # dasherize, camelize, underscore, classify

  @inject: (props)->
    return unless @type?
    if @type is 'module'
      @moduleDeps=  [@moduleDeps or [], Array.create(arguments)].flatten()
      @module= Ng.getTransformedName(@) if @module is 'app'
      Ng.getModule @, yes
      moduleName= @module
      class this.Base extends Ng.Base then @module: moduleName
      class this.Controller extends Ng.Controller then @module: moduleName
      class this.Service extends Ng.Service then @module: moduleName
      class this.Factory extends Ng.Factory then @module: moduleName
      # console.debug "ng-core: angular.module('#{@module}', #{JSON.stringify @moduleDeps})"
    else
      Ng.annotateDependencies @, props
      Ng.getModule(@)[ @type ]( Ng.getTransformedName(@), this )
      # console.debug "ng-core: angular.module('#{@module}').#{@type}('#{Ng.getTransformedName(@)}', ...)"

  @animation: (name, fn)->
    def= if typeof fn is 'function' then fn else (-> fn)
    Ng.getModule(@).animation name, def
  @config: (fn)->
    Ng.getModule(@).config fn
  @directive: (name, config)->
    def= if typeof config is 'function' then config else (-> config)
    Ng.getModule(@).directive name, def
  @filter: (name, fn)->
    Ng.getModule(@).filter name, (-> fn)
  @run: (fn)->
    Ng.getModule(@).run fn
  @constant: (name, value)->
    Ng.getModule(@).constant name, value
  @value: (name, value)->
    Ng.getModule(@).value name, value

  constructor: (injected...)->
    if (type= @$get?.type) and type is 'factory'
      return new @$get injected...
    Ng.assignDependencies this, injected
    init_result= @initialize? injected...
    return init_result if @constructor.type is 'factory'

class Ng.Module extends Ng.Base
  @nameTransform: 'dasherize'
  @type: 'module'
class Ng.Controller extends Ng.Base
  @type: 'controller'
class Ng.Service extends Ng.Base
  @nameTransform: 'camelize'
  @type: 'service'
class Ng.Factory extends Ng.Base
  @type: 'factory'
