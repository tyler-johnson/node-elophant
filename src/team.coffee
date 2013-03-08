EventEmitter = require('events').EventEmitter
_ = require 'underscore'
api = require "./api"
nconf = require 'nconf'

class Team extends EventEmitter
	constructor: (id, options) ->
		@options = _.defaults options or {},
			tagOrName: false,
			cache: true,
			region: nconf.get("ELOPHANT:REGION"),
			apikey: nconf.get("ELOPHANT:APIKEY")

		@cache = {}

		if _.isString(id)
			if @options.tagOrName
				@_call "find_team", id, (err, data) =>
					if err then @emit "error", err
					if data then @_init data
			else
				@_call "team", id, (err, data) =>
					if err then @emit "error", err
					if data then @_init data
		else if _.isObject(id) then @_init id

	_init: (data) ->
		_.each data, (v, k) =>
			unless _.has(@, k) then @[k] = v
		
		if _.isObject(@teamStatSummary) then @teamId = @teamStatSummary.teamId.fullId;
		@emit "ready"

	_handle: (method, args..., cb) ->
		if @options.cache and _.has(@cache, method)
			cache = @cache[method]
			if _.isFunction(cb) then cb(null, cache)
			else return cache
		else @_call method, args, cb

	_call: (method, args..., cb) ->
		callback = (err, data) =>
			if data and @options.cache then @cache[method] = data
			if _.isFunction(cb) then cb.apply null, arguments

		a = _.chain([args, { region: @options.region, apikey: @options.apikey }, callback]).flatten().compact().value()
		api[method].apply null, a

	# Actual API Methods
	endOfGameStats: (gid, cb) ->
		return @_handle "team_end_of_game_stats", @teamId, gid, cb

	rankedStats: (cb) ->
		return @_handle "team_ranked_stats", @teamId, cb

module.exports = Team