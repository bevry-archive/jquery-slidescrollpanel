# This file was originally created by Benjamin Lupton <b@lupton.cc> (http://balupton.com)
# and is currently licensed under the Creative Commons Zero (http://creativecommons.org/publicdomain/zero/1.0/)
# making it public domain so you can do whatever you wish with it without worry (you can even remove this notice!)
#
# If you change something here, be sure to reflect the changes in:
# - the scripts section of the package.json file
# - the .travis.yml file


# -----------------
# Variables

WINDOWS = process.platform.indexOf('win') is 0
NODE    = process.execPath
NPM     = if WINDOWS then process.execPath.replace('node.exe','npm.cmd') else 'npm'
EXT     = (if WINDOWS then '.cmd' else '')
APP     = process.cwd()
BIN     = "#{APP}/node_modules/.bin"
CAKE    = "#{BIN}/cake#{EXT}"
COFFEE  = "#{BIN}/coffee#{EXT}"
DOCPAD  = "#{BIN}/docpad#{EXT}"
OUT     = "#{APP}/out"
SRC     = "#{APP}/src"


# -----------------
# Requires

pathUtil = require('path')
{exec,spawn} = require('child_process')
safe = (next,fn) ->
	return (err) ->
		return next(err)  if err
		return fn()


# -----------------
# Actions

bench = (opts,next) ->
	(next = opts; opts = {})  unless next?
	spawn(NODE, ["#{OUT}/test/benchmark.js"], {stdio:'inherit',cwd:APP}).on('exit',next)

clean = (opts,next) ->
	(next = opts; opts = {})  unless next?
	args = [
		'-Rf'
		OUT
		pathUtil.join(APP,'node_modules')
		pathUtil.join(APP,'*out')
		pathUtil.join(APP,'*log')
	]
	spawn('rm', args, {stdio:'inherit',cwd:APP}).on('exit',next)

compile = (opts,next) ->
	(next = opts; opts = {})  unless next?
	spawn(DOCPAD, ['generate'], {stdio:'inherit',cwd:APP}).on('exit',next)

watch = (opts,next) ->
	(next = opts; opts = {})  unless next?
	spawn(DOCPAD, ['watch'], {stdio:'inherit',cwd:APP}).on('exit',next)

install = (opts,next) ->
	(next = opts; opts = {})  unless next?
	spawn(NPM, ['install'], {stdio:'inherit',cwd:APP}).on('exit',next)

reset = (opts,next) ->
	(next = opts; opts = {})  unless next?
	clean opts, safe next, -> install opts, safe next, -> compile opts, next

setup = (opts,next) ->
	(next = opts; opts = {})  unless next?
	install opts, safe next, ->
		compile opts, next

test = (opts,next) ->
	(next = opts; opts = {})  unless next?
	args = []
	args.push("--debug-brk")  if opts.debug
	args.push("--joe-reporter=list")
	args.push("#{OUT}/test/everything-test.js")
	spawn(NODE, args, {stdio:'inherit',cwd:APP}, next)

finish = (err) ->
	throw err  if err
	console.log('OK')


# -----------------
# Commands

# bench
task 'bench', 'benchmark our project', ->
	bench finish

# clean
task 'clean', 'clean up instance', ->
	clean finish

# compile
task 'compile', 'compile our files', ->
	compile finish

# dev/watch
task 'dev', 'watch and recompile our files', ->
	watch finish
task 'watch', 'watch and recompile our files', ->
	watch finish

# install
task 'install', 'install dependencies', ->
	install finish

# reset
task 'reset', 'reset instance', ->
	reset finish

# setup
task 'setup', 'setup for development', ->
	setup finish

# test
task 'test', 'run our tests', ->
	test finish

# test-debug
task 'test-debug', 'run our tests in debug mode', ->
	test {debug:true}, finish

# test-prepare
task 'test-prepare', 'prepare out tests', ->
	setup finish

