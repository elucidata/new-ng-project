setup_synco= (opts)->
  opts.env or= 'remote'
  opts.stage= opts.env
  opts.dryrun= opts.dryrun or false
  opts.verbose= opts.verbose or false
  opts.force= opts.force or false
  syncodemayo= require './lib/syncodemayo'


# option '-d', '--dryrun', 'sync: simulate and only report change'
option '-e', '--env [ENVIRONMENT_NAME]', 'sync: set the target environment'
option '-v', '--verbose', 'sync: verbose logging'
task 'sync', 'Sync to server using FTP', (opts)->
  setup_synco(opts).run opts

task 'sync:production', 'Sync to production server using FTP', (opts)->
  opts.env= 'production'
  setup_synco(opts).run opts

option '-f', '--force', 'sync:init: force over-write filelist'
task 'sync:init', 'Initializes server for use with SyncoDeMayo', (opts)->
  setup_synco(opts).init opts

task 'sync:check', 'Checks for SyncoDeMayo compatibility.', (opts)->
  setup_synco(opts).check opts
