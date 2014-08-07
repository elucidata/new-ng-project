# You'll probably not want to commit this to the repo...
module.exports=

  local:
    path: 'www'
    files: '**/**'
    exclude: ["**/*.map", "**/.DS_Store", "**/.git*"]

  remote:
    path: 'site/wwwroot'
    host: 'my.ftpserver.com'
    user: 'USERNAME'
    pass: 'PASSWORD'
    port: 21
    cache: '.synco-filelist'
