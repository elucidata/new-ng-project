require('dotenv').load()

global.PATH=
  APP:    "./app"
  ASSETS: "./app/assets"
  BUILD:  "./www"
  LIB:    "./tasks/lib"
  TASKS:  "./tasks"

require 'coffee-script/register'
require 'shelljs/global'
require "#{ PATH.LIB }/build-helpers"

# Auto load tasks from tasks/...
require "./#{ taskfile.replace(/\.coffee$/, '') }" for taskfile in ls "#{ PATH.TASKS }/*.coffee"
