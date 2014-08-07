
task 'clean', "Removes #{PATH.BUILD}", ->
  rm '-rf', PATH.BUILD

task 'clean:misc', 'Removes all .DS_Store files from project folder', ->
  exec_loud "find . -name '*.DS_Store' -type f -delete"
