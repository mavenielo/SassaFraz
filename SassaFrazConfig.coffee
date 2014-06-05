fs = require "fs"
system = require "system"
eol = if system.os.name is 'windows' then "\r\n" else "\n"

class SassaFrazConfig
	keywords: [
		"settings:"
		"pages:"
		"import:"
		"rooted-selectors:"
		"css-bases:"
		"based-on:"
		]
	settings:
		"ignore-tags" : "0"
		"rooted-file" : "rooted.scss"
	pages:[]
	import:[]
	rooted_selectors:[]
	css_bases:[]
	based_on:[]
	bases:{}

	constructor: (path) ->
		try
			f = fs.open path, "r"
			content = f.read()
			f.close()
		catch e
			console.log e

		if content?
			@Parse content.split eol
			@LoadBasis()

	Parse: (lines) ->
		@ParseKeywordSection keyword, lines for keyword in @keywords

	CleanKeyword: (keyword) ->
		keyword.replace(":", "").replace "-", "_"

	ParseKeyValue: (keyword, property, lines, separator = ",", key = "selector", value = "base") ->
		is_key_value = key is"key" and value is "value"
		list = @[property]
		parsing = false
		for line in lines

			trimline = line.trim()
			keywordline = @keywords.indexOf(trimline) > -1

			if !parsing and trimline == keyword
				parsing = true
			else if parsing and not keywordline and trimline isnt "" and trimline[0] isnt "#"
				parts = line.split separator
				if parts.length is 2
					obj = {}
					if is_key_value
						list[parts[0].trim()] = parts[1].trim()
					else
						obj[key] = parts[0].trim()
						obj[value] = parts[1].trim()
						list.push obj
			else if parsing and keywordline
				break
		list

	ParseKeywordSection: (keyword, lines) ->
		property = @CleanKeyword keyword
		k = keyword
		@separator = if k is "based-on:" then "<" else if k is "pages:" then ">" else  if k is "settings:" then "=" else ""

		if @separator isnt ""
			key = if k is "pages:" then "url" else  if k is "settings:" then "key" else undefined
			val =  if k is "pages:" then "sass" else  if k is "settings:" then "value" else undefined
			return @[property] = @ParseKeyValue keyword, property, lines, @separator, key, val

		list = @[property]
		parsing = false
		for line in lines
			trimline = line.trim()
			keywordline = @keywords.indexOf(trimline) > -1
			if !parsing and trimline == keyword
				parsing = true
			else if parsing and not keywordline and trimline isnt "" and trimline[0] isnt "#"
				list.push line.trim()
			else if parsing and keywordline
				break

		@[property] = list

	LoadBasis: ->
		@LoadBase css_base for css_base in @css_bases

	LoadBase: (path) ->

		if not fs.exists path
			f = fs.open path, "w"
			f.write ".css {\n}"
			f.close()

		f = fs.open path, "r"
		content = f.read()
		f.close()

		for base, definition of @GetCSSDefinitions content
			@bases[base] = definition

		@bases

	Merge: (definition, previous = "") ->
		next = previous

		# This can be improved by checking individual attributes, split using ; and then :
		if -1 < previous.indexOf definition
			return previous

		next += definition

		return next

	GetCSSDefinitions: (content) ->
		#css_regex = /([a-zA-Z0-9-_.#\s]*)\s*\{\s*([a-zA-Z0-9-_:;\s]*)\}\s*/
		defs = {}
		for based_on in @based_on
			based_on_base = based_on.base.replace /(\.)/g, (match) ->
				#escape periods
				match ="\\\."
			for base in based_on_base.split ","
				css_regex = new RegExp "#{base.trim()}\\s*\\{\\s*([a-zA-Z0-9-_:;\\s\\$\\(\\)\\,\\.]*)\\}\\s*", "g"
				css_def_regex = new RegExp ".\\{([a-zA-Z0-9-_:;\\s\\$\\(\\)\\,\\.]*)\\}*", "g"

				if def = content.match(css_regex)[0]
					if def = def.match(css_def_regex)[0].trim().replace("{", "").replace("}", "")
						def = @Merge def, defs[based_on.selector]
						defs[based_on.selector] = def
		defs

	Debug: ->
		for keyword in @keywords
			property = @CleanKeyword keyword
			console.log "\n#{keyword}\n#{JSON.stringify @[property]}"

		console.log "\n"

exports.create = (path) ->
		new SassaFrazConfig path
