page = require('webpage').create()
system = require 'system'

is_casper = 2 < system.args.length and system.args[0].indexOf "casper" isnt false

if (is_casper and system.args.length isnt 5) or (not is_casper and system.args.length isnt 2)
	console.log """\n
		Usage: #{if is_casper then "casper" else "phantom"}js frazzle.js /path/to/fraz/file\n
		The following parameters were passed to phantomjs:\n
		#{("\t\t#{parameter}\n" for parameter in system.args).join ""}
		\n"""
	phantom.exit()

config_path = system.args[if is_casper then 4 else 1]

console.log "\n#{config_path}"

sassaFraz = require("./SassaFraz").create config_path, (fraz)->
	console.log "All pages processed."

	fraz.SaveToFiles()

	phantom.exit()
