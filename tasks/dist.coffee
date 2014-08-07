
option '-f', '--force', 'dist: Skips check for modified repo files.'
task 'dist', "Builds optimized version from clean slate, syncs to TEST", (options)->
  options.force or= no
  # git_ensure_clean() unless options.force
  invoke 'build'
  invoke 'sync'

task 'dist:production', "Builds optimized version from clean slate, syncs to PRODUCTION", (options)->
  options.force or= no
  # git_ensure_clean() unless options.force
  invoke 'build:production'
  invoke 'sync:production'
