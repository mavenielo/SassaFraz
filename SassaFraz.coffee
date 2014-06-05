exports.create = (config_path, death_callback) ->
	fs = require "fs"
	system = require "system"

	String::TrimLeft = (charlist = "\s") ->
		@replace(new RegExp("^[#{charlist}]+"), "")

	String::TrimLeft = (charlist = "\s") ->
		@replace(new RegExp("[#{charlist}]+$"), "")

	String::Trim = (charlist = "\s") ->
		@TrimLeft(charlist).TrimRight charlist

	class SassaFraz

		config: require("./SassaFrazConfig").create config_path

		beatingHeart: null
		loadCount: 0
		pages:[]

		busy_frazzling : false

		imports_output: []
		hierarchies: {}
		rooted: {}
		outputs: {}

		constructor: (path) ->
			_this = @
			@config.Debug()

			pulse = -> _this.CheckPulse()
			death = -> death_callback _this

			@beatingHeart = require("./BeatingHeart").create pulse, death

			@LoadPages()

		CheckPulse: ->
			if @buzy_frazzling
				console.write "."
			not @LastBreath()

		LastBreath: ->
			@AllPageLoaded() and @HasFrazzled()

		HasFrazzled: ->
			return if not @AllPageLoaded() or @busy_frazzling then false else @Frazzle()

		Frazzle: ->
			@busy_frazzling = true
			console.log "\nFrazzelling ..."
			@imports_output.push """@import '#{file}';\n""" for file in @config.import

			for identifier, hierarchy of @hierarchies
				console.log "\n" + identifier
				@Traverse identifier, hierarchy

		PrintTo: (i, string) ->
			@outputs[i].push string

		Traverse: (index = -1, node, indent = "") ->
			for key, value of node
				thin_key = key.trim()
				_indent = indent

				if thin_key != ""
					@PrintTo index, "#{indent}#{key} {"
					@PrintBase key, index, indent
					_indent = "	#{indent}"

				@Traverse index, value, _indent

				if thin_key != ""
					linefeed = if indent == "" then "\n" else ""
					@PrintTo index, "#{indent}}#{linefeed}"
			true

		PrintBase: (key, index, indent) ->
			keys = []
			keys = keys.concat k.trim().replace(new RegExp("^[\.]+"), "").split new RegExp("[\.#]+") for k in key.split ","
			console.log "#{indent} - #{JSON.stringify keys}"

			found = false
			for base, definition of @config.bases when not -1 < keys.indexOf base.replace(new RegExp("^[\.]+"), "")
				@PrintTo index, "#{indent}	#{line.trim()}" for line in definition.split "\n" when line.trim() isnt ""
				return

		IsRooted: (full_selectors) ->
			for full_selector in full_selectors.split ","
				for part in full_selector.trim().split "."
					for rooted_selector in @config.rooted_selectors when rooted_selector.replace(new RegExp("^[\.]+"), "") is part
						#console.log "full_selectors #{full_selectors}"
						return true
			false

		Process: (webpage, identifier) ->
			webpage.injectJs 'jquery-2.1.0.min.js'
			webpage.injectJs 'SassaFrazzlerClient.js'
			@outputs[identifier] = []

			# Passing the function as a string allows me to inject the config data into
			# the webpage scope as JSON.
			@hierarchies[identifier] = webpage.evaluate """
				function () {
					return (new SassaFrazzlerClient(#{JSON.stringify @config})).GetFullPageHierarchy();
				}
				"""

		AllPageLoaded: ->
			@loadCount is @config.pages.length

		LoadPages: ->
			@LoadPage page for page in @config.pages

		LoadPage: (page) ->
			_this = @
			webpage = require('webpage').create()
			@pages.push webpage

			#webpage.onResourceReceived = (response) ->
			#	console.log "Receive #{JSON.stringify(response, undefined, 4)}";

			console.log "Loading #{page.url}"

			is_mustache = -1 < page.url.indexOf ".mustache"
			url = if is_mustache then "skeleton.html" else page.url

			webpage.open url, (status) ->

				if is_mustache
					console.log "Mustache file"
					f = fs.open page.url, "r"
					content = f.read()
					f.close()
					webpage.setContent content, page.url

				console.log "Loaded #{page.url}"
				_this.Process webpage, page.url
				_this.loadCount++

		SaveToFiles: ->
			for page, i in @config.pages
				@SaveToFile page, i

		SaveToFile: (page, i = -1) ->
			output_list = @outputs[page.url]
			output = output_list.join "\n"
			plus_index = page.sass.indexOf "+"
			content = ""
			path = page.sass.replace "+", ""

			imports = @imports_output.join("") + "\n"

			overwrite = true
			prepend = false

			if -1 < plus_index
				content = fs.read path
				overwrite = false
				if plus_index is 0
					prepend = true
				else
					prepend = false

				if -1 < content.indexOf imports
					content = content.replace imports, ""

			f = fs.open path, "w"

			f.write imports + (if overwrite then output else if prepend then output+"\n"+content else content+"\n"+output)

			f.close()

			console.log "#{path} : Saved"

	new SassaFraz()