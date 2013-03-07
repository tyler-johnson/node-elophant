EventEmitter = require('events').EventEmitter
_ = require 'underscore'
api = require "./api"
nconf = require 'nconf'

class Summoner extends EventEmitter
	constructor: (name, options) ->
		@options = _.defaults options or {},
			cache: true,
			region: nconf.get("ELOPHANT:REGION"),
			apikey: nconf.get("ELOPHANT:APIKEY")

		@cache = {}

		if _.isString(name)
			@_call "summoner", name, (err, data) =>
				if err then @emit "error", err
				if data then @_init data
		else if _.isObject(name) then @_init name
		else if _.isNumber(name)
			@_call "summoner_names", name, (err, data) =>
				if err then @emit "error", err
				if _.isArray(data) and data.length
					@_call "summoner", data[0], (err, d) =>
						if err then @emit "error", err
						if d then @_init d

	_init: (data) ->
		_.each data, (v, k) =>
			unless _.has(@, k) then @[k] = v
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

	# Actual API
	masteryPages: (cb) ->
		return @_handle "mastery_pages", @summonerId, cb

	runePages: (cb) ->
		return @_handle "rune_pages", @summonerId, cb

	recentGames: (cb) ->
		return @_handle "recent_games", @acctId, cb

	leagues: (cb) ->
		return @_handle "leagues", @summonerId, cb

	summonerTeamInfo: (cb) ->
		return @_handle "summoner_team_info", @summonerId, cb

	inProgressGameInfo: (cb) ->
		return @_handle "in_progress_game_info", @name, cb

	rankedStats: (season, cb) ->
		if _.isFunction(season) then [cb, season] = [season, null]
		return @_handle "ranked_stats", @acctId, season, cb

module.exports = Summoner