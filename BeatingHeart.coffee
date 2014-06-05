exports.create = (pulse_callback, death_callback, bpm=14) ->
	class BeatingHeart

		bpm:14
		heart: null
		Death: null
		Pulse: null

		constructor: (pulse, death)->
			@Pulse = pulse
			@Death = death
			@bpm = bpm
			@StartHeartBeat()

		StartHeartBeat: ->
			_this = @
			heartBeat = ->
				_this.HeartBeat()
			heart = setInterval heartBeat, @HeartRate

		StopHeartBeat: ->
			@heart = clearInterval @heart
			@Death @

		HeartBeat: ->
			if !@Pulse()
				@StopHeartBeat()

		IsAlive: ->
			return @heart?

		HeartRate: ->
			1000 * 60 / bpm

	new BeatingHeart(pulse_callback, death_callback)