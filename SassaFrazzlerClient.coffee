$ = jQuery

@SassaFrazzlerClient =
class SassaFrazzlerClient
	hierarchy: null
	filtered_hierarchy: {}
	config: null

	constructor: (config) ->
		@config = config
		@hierarchy = @MakeList $('body')
		@FilterByConfig()
		@CleanUp()

	GetFullPageHierarchy: ->
		@hierarchy

	CleanUp: ->
		hierarchy_info =
			node : @hierarchy
			key: undefined
			ancestry : undefined

		hierarchy_info = @CleanUpTraverse hierarchy_info

		@hierarchy = hierarchy_info.node

	CleanUpTraverse: (hierarchy_info) ->
		for key of hierarchy_info.node
			node_hierarchy_info =
				node : hierarchy_info.node[key]
				key: key
				ancestry : hierarchy_info

			node_hierarchy_info = @CleanUpTraverse node_hierarchy_info

			hierarchy_info.node[key] = node_hierarchy_info.node

		@CleanUpNode hierarchy_info

	CleanUpNode: (hierarchy_info) ->
		if hierarchy_info.node? and hierarchy_info.node[""]?
			console.log JSON.stringify hierarchy_info.node[""]
			console.log JSON.stringify hierarchy_info.ancestry
			nameless_node = $.extend true, {}, hierarchy_info.node[""]
			delete hierarchy_info.node[""]

			new_node = $.extend true, {}, hierarchy_info.node, nameless_node
			hierarchy_info.node = new_node

		sorted = []
		sorted[sorted.length] = key for key of hierarchy_info.node
		sorted.sort();

		new_hierarchy_info =
			node: {}
			key: hierarchy_info.key
			ancestry : hierarchy_info.ancestry

		new_hierarchy_info.node[key] = hierarchy_info.node[key] for key in sorted

		new_hierarchy_info

	FilterByConfig: ->
		@filtered_hierarchy = @hierarchy

		@filtered_hierarchy = @FilterRooted @filtered_hierarchy
		@filtered_hierarchy

	FilterRooted: (hierarchy) ->
		for key, value of hierarchy
			if @IsRooted key
				@filtered_hierarchy[key] = if @filtered_hierarchy[key]? then $.extend true, @filtered_hierarchy[key], value else value
				if @config.settings["keep-rooted-stubs"]? and @config.settings["keep-rooted-stubs"] is "1"
					hierarchy[key] = undefined
				else
					delete hierarchy[key]
			else
				hierarchy[key] = @FilterRooted value for key, value of hierarchy

		hierarchy

	IsRooted: (full_selectors) ->
		for full_selector in full_selectors.split ","
			for selector_part in full_selector.trim().split "."
				for rooted_selector in @config.rooted_selectors when rooted_selector.replace(new RegExp("^[\.]+"), "") is selector_part
					return true
		false

	CSSClassify: (cls) ->
		if cls is undefined
			return ""

		if cls.trim() is ""
			return ""

		#Ensure single whitespaces
		while -1 < cls.indexOf "  "
			cls = cls.replace "  ", " "

		#Turn into selector
		while -1 < cls.indexOf " "
			cls = cls.replace " ", "."

		return ".#{cls}"

	MakeList: (element) ->
		_this = @
		list = {}

		tag = if @config.settings["ignore-tags"] is "1" then "" else $(element).prop 'tagName'
		cls = @CSSClassify $(element).attr 'class'
		id = $(element).attr 'id'

		keys = []

		if id? and id isnt ""
			keys.push "#{tag}##{id}"
		if cls? and cls isnt ""
			keys.push "#{tag}#{cls}"

		key = keys.join ", "

		list[key] = list[key] ? {}

		for el in $(element).children()
			list[key] = $.extend true, list[key], @MakeList el

		list
