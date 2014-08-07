# Example .syncodemayo.json:
# {
#   "local": {
#     "path": "www",
#     "files": "**/**",
#     "exclude": ["**/*.map", "**/.DS_Store", "**/.git*"]
#   },
#
#   "remote": {
#     "path": "JobTracker/Client",
#     "host": "www.freedomparktest.com",
#     "user": "USERNAME",
#     "pass": "PASSWORD",
#     "port": 21,
#     "cache": ".synco-filelist"
#   },
#
#   "production": {
#     "path": "JobTracker/Client",
#     "host": "www.freedomparkdfw.com",
#     "user": "USERNAME",
#     "pass": "PASSWORD",
#     "port": 21,
#     "cache": ".synco-filelist"
#   }
# }

require 'coffee-script/register'
Promise= require 'bluebird'
Ftp= require 'jsftp'
Ftp= require('jsftp-mkdirp')(Ftp)
glob= require 'glob'
path= require 'path'
crc= require 'crc'
fs= require 'fs'
_= require 'lodash'

Promise.promisifyAll fs
conn= null
config= {}
opts=
  verbose: no
  force: no

log= ->
  if opts.verbose
    console.log arguments...

connect= (config)->
  new Promise (resolve, reject)->
    # Connect to ftp
    {host, port, user, pass}= config
    log "Connecting to FTP:", {host, port, user, pass}
    conn= new Ftp {host, port, user, pass}
    resolve conn

get_file= (filename)->
  log "Retrieve:", filename
  content= ""
  new Promise (resolve, reject)->
    conn.get filename, (err, socket)->
      return reject(err) if err?
      socket.on "data", (d)-> content += d.toString()
      socket.on 'error', (err)->
        console.log "Retrieval error."
        reject(conn_err)
      socket.on "close", (conn_err)->
        if conn_err
          reject(conn_err)
        else
          resolve(content)
      socket.resume()

verify_dir= (pathname)->
  new Promise (resolve, reject)->
    conn.mkdirp pathname, (err)->
      if err
        reject err
      else
        resolve yes

put_buff= (buff, remote_path)->
  new Promise (resolve, reject)->
    console.log " ->", remote_path
    conn.put buff, remote_path, (err)->
      if err then reject err
      else resolve remote_path

put_content= (content, remote_path)->
  put_buff new Buffer(content), remote_path

put_file= (filename, remote_path)->
  new Promise (resolve, reject)->
    fs.readFileAsync filename
      .then (buffer)->
        put_buff buffer, remote_path
          .then -> resolve remote_path
          .catch (err)-> reject err

load_local= (pathname)->
  log "Require:", pathname
  new Promise (resolve, reject) ->
    if typeof pathname isnt 'string'
      return reject new Error "Path must be a string. Got a #{ typeof pathname }"
    data= require pathname
    data._path= pathname if typeof data is 'object'
    resolve data

get_config= (opts={})-> # opts from CLI
  log "SyncoDeMayo, getting started..."
  Promise.any [
      load_local(opts.config)
      load_local('.syncodemayo')
      load_local('syncodemayo')
    ]

get_remote_filelist= (config)->
  pathname= "#{ config.path }/#{ config.cache }"
  console.log " <-", pathname
  get_file pathname
    .then JSON.parse
    .catch (err)->
      console.log "Missing or error parsing remote file list.", err
      console.log "\n   Run sync:init to setup SyncoDeMayo on the server.\n"
      process.exit 1
      {}

build_local_filelist= (config)->
  log  "Create CRCs:"
  Promise.resolve "#{ config.path }/#{ config.files or '**/**' }"
    .then (pathname)->
      log 'Glob: ', pathname
      glob.sync pathname
    .then (paths)->
      _(paths)
        .filter (pathname)->
          stat= fs.statSync(pathname)
          !stat.isDirectory()
        .unique()
        .compact()
        .value()
    .then (paths)->
      filelist= {}
      for pathname in paths
        filelist[ pathname ]= crc.crc32 fs.readFileSync pathname
      filelist

startup= (options={})->
  opts= _.defaults options, opts
  get_config(opts)
    .then (conf)->
      throw new Error "Config not found." unless conf?
      conf._stage= opts._stage= conf[ opts.stage or 'remote' ]
      conf
    .then (conf)->
      config= conf
      connect conf._stage
    .then (conn)->
      console.log "Connected to #{ config._stage.host }"
      conn

global_error_handler= (err)->
  console.log "Error processing sync:"
  console.log err.message or 'Unknown error'
  console.error err

cleanup= ->
  conn?.raw?.quit? (err, data)->
    if err?
      console.error err

file_exists= (remote_path)->
  new Promise (resolve, reject)->
    conn.raw.size remote_path, (err, size)->
      # log "SIZE OF", remote_path, "IS", size
      if err
        resolve no
      else
        resolve yes

api=
  check: (options={})->
    log "Checking server...."
    startup(options)
      .then ->
        log "Connected to server."
        remote_path= "#{ config._stage.path }/#{ config._stage.cache }"
        file_exists remote_path
      .then (exists)->
        if exists
          console.log "#{ config._stage.host } appears ready to sync."
        else
          console.log "It looks like you need to run sync:init for #{ config._stage.host }"
      .catch global_error_handler
      .finally cleanup

  init: (options={})->
    startup(options)
      .then ->
        log "Connected to server."
        remote_path= "#{ config._stage.path }/#{ config._stage.cache }"
        file_exists remote_path
          .then (exists)->
            if exists
              if opts.force
                console.log "#{ config._stage.host } already is initialized, forcing over-write of existing filelist"
              else
                console.log "#{ config._stage.host } already is initialized, to re-initialize use the --force option"
                throw new Error "Already initialized"
            else
              yes
          .then ->
            log "Updating remote filelist:", remote_path
            verify_dir path.dirname remote_path
              .then (success)->
                if success
                  put_content "{}", remote_path,
                else
                  console.error "Directory error."
                  throw new Error "Directory creation error."
      .catch global_error_handler
      .finally cleanup

  run: (options={})->
    startup(options)
      .then ->
        remote_path= "#{ config._stage.path }/#{ config._stage.cache }"
        file_exists(remote_path)
      .then (is_configured)->
        throw new Error "#{ config._stage.host } doesn't appear to be configured. Run sync:init." unless is_configured
        is_configured
      .then (c)->
        remote_files=null
        local_files= null
        changed_files= null
        log "Connected to server." #, conn

        Promise.all [
            get_remote_filelist( config._stage ) #.catch -> log "Failed to get remote filelist. Is this the first run, perhaps?"
            build_local_filelist( config.local )
          ]
          .then ([ remote, local ])->
            log "Remote filelist:", remote
            log "Local filelist:", local
            remote_file= remote
            local_files= local
            filename for filename, hash of local when remote[ filename ] != hash
          .then (changed)->
            log "Changed files:", changed
            changed_files= changed
            current= Promise.fulfilled()
            Promise.all changed.map (filename)->
              remote_path= "#{ config._stage.path }#{ filename.replace(config.local.path, '') }"
              current= current.then -> verify_dir path.dirname remote_path
                .then ->
                  put_file filename, remote_path
          .then ->
            if changed_files.length
              remote_path= "#{ config._stage.path }/#{ config._stage.cache }"
              log "Updating remote filelist:", remote_path
              verify_dir path.dirname remote_path
                .then (success)->
                  if success
                    put_content JSON.stringify(local_files, null, 2), remote_path
                  else
                    console.error "Directory error."
                    throw new Error "Directory creation error."

            else
              console.log "No changed files."
      .catch global_error_handler
      .finally cleanup

module.exports= api
