page = require('webpage').create()
system = require 'system'

if system.args.length isnt 5
	console.log "Usage: sandbox.js /path/to/fraz/file"
	console.log JSON.stringify system.args
	phantom.exit()

config_path = system.args[4]
console.log "\n#{config_path}"

sassaFraz = require("./SassaFraz").create config_path, (fraz)->
	console.log "All pages processed."
	#console.log "/* Imports */"
	#console.log fraz.imports_output.join "\n"
	#console.log "/* Basic */"
	#console.log output.join "\n" for output in fraz.outputs
	#console.log "/* Rooted */"
	#console.log fraz.rooted_output.join "\n"

	fraz.SaveToFiles()

	phantom.exit()
