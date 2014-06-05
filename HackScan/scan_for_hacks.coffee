page = require('webpage').create()
system = require 'system'

page_list = [
	"www.imperialselect.co.za",
	"www.google.co.za"
]

console.log "Starting..."
hackScan = require("./HackScan").create page_list, (fraz)->
	console.log "All pages processed."
	phantom.exit()
