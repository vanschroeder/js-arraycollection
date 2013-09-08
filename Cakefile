# require Node::FS
fs = require 'fs'
# require Node::Util
{debug, error, log, print} = require 'util'
# import Spawn and Exec from child_process
{spawn, exec, execFile}=require 'child_process'
# colors
red   = "\u001b[0;31m"
green = "\u001b[0;32m"
reset = "\u001b[0;0m"
# try to import the Which module
try
  which = (require 'which').sync
catch err
  if process.platform.match(/^win/)?
    error 'The which module is required for windows. try "npm install which"'
  which = null
# paths object for module invocation reference
paths={
  "coffee": [
    "lib",
    "src"
  ],
  "uglify": [
    "lib"
  ],
}
# file extensions for watching
exts='coffee|jade'
# Begin Callback Handlers
# Callback From 'coffee'
coffeeCallback=()->
  exec 'cp lib/sparse.js ../sparse-demo/src/assets/javascript'
# Callback From 'docco'
doccoCallback=()->

# Begin Tasks
# ## *build*
# Compiles Sources
task 'build', 'Compiles Sources', ()-> build -> log ':)', green
build = ()->
  # From Module 'coffee'
  # Enable coffee-script compiling
  launch 'coffee', (['-c', '-b', '-o' ].concat paths.coffee), coffeeCallback

# ## *watch*
# watch project src folders and build on change
task 'watch', 'watch project src folders and build on change', ()-> watch -> log ':)', green
watch = ()->
  exec "supervisor -e '#{['.coffee']}' -n exit -q -w '#{paths.coffee[1]}' -x 'cake' build"
# ## *minify*
# Minify Generated JS and HTML
task 'minify', 'Minify Generated JS and HTML', ()-> minify -> log ':)', green
minify = ()->
  # minify js and html paths
  if paths? and paths.uglify?
    walk paths.uglify[0], (err, results) =>
      for file in results
        if file.match /(^\.min+)\.js+$/
          launch 'uglifyjs', ['-c', '--output', "#{file.replace /\.js+$/,'.min.js'}", file]

# ## *docs*
# Generate Documentation
task 'docs', 'Generate Documentation', ()-> docs -> log ':)', green
docs = ()->
  # From Module 'docco'
  #
  if (moduleExists 'docco') && paths? && paths.coffee?
    walk paths.coffee[1], (err, paths) ->
      try
        launch 'docco', paths, doccoCallback()
      catch e
        error e

# ## *test*
# Runs your test suite.
task 'test', 'Runs your test suite.', (options=[],callback)-> test -> log ':)', green
test = (options=[],callback)->
  # From Module 'mocha'
  #
  if moduleExists('mocha')
    if typeof options is 'function'
      callback = options
      options = []
    # add coffee directive
    options.push '--compilers'
    options.push 'coffee:coffee-script'
    options.push '--reporter'
    options.push 'spec'
    
    launch 'mocha', options, callback
    
task 'import:demo', 'Import the demo project build', (callback)-> import_demo -> log ':)', green
import_demo = (callback)->
  exec 'cp -r ../sparse-demo/demo .'

# Begin Helpers
#  
launch = (cmd, options=[], callback) ->
  cmd = which(cmd) if which
  app = spawn cmd, options
  app.stdout.pipe(process.stdout)
  app.stderr.pipe(process.stderr)
  app.on 'exit', (status) -> callback?() if status is 0#  
log = (message, color, explanation) -> 
  console.log color+message+reset+(explanation or '')#  
moduleExists = (name) ->
  try 
    require name 
  catch err 
    error "#{red}#{name} required: npm install #{name}#{reset}"
    false
walk = (dir, done) ->
  results = []
  fs.readdir dir, (err, list) ->
    return done(err, []) if err
    pending = list.length
    return done(null, results) unless pending
    for name in list
      continue if name.match /^\./
      file = "#{dir}/#{name}"
      try
        stat = fs.statSync file
      catch err
        stat = null
      if stat?.isDirectory()
        walk file, (err, res) ->
          results.push name for name in res
          done(null, results) unless pending
      else
        results.push file
        done(null, results)