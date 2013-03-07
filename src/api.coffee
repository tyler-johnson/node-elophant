path = require 'path'
qs = require 'querystring'
_ = require 'underscore'
request = require 'request'
nconf = require 'nconf'
async = require 'async'
Summoner = require './summoner'

ELOPHANT_BASE = "http://api.elophant.com/v2/"
ELOPHANT_REGIONS = [ "na", "euw", "eune", "br" ]

buildURL = module.exports.buildURL = (region, apikey, args...) -> # 
	unless !region or _.contains(ELOPHANT_REGIONS, region) then console.error("Region #{region} isn't support by Elophant and will likely fail.");
	apikey = if apikey then "?" + qs.stringify({ key: apikey }) else ""
	args = _.chain(args).flatten().compact().map(encodeURIComponent).value()
	method = args.join("/") or null

	return ELOPHANT_BASE + path.join(region, method) + apikey

callAPI = module.exports.callAPI = (url, cb) ->
	request { uri: url, json: true }, (err, res, body) ->
		if err then cb err
		else if res.statusCode >= 400 or !_.isObject(body) then cb new Error "Couldn't connect to the given resource."
		else if body.success and body.data then cb null, body.data
		else if body.error then cb new Error body.error
		else cb new Error "Unknown error occured while making request."

buildOptionsCallback = (options, callback) ->
	if _.isFunction(options) then [callback, options] = [options, {}]
	if !_.isFunction(callback) then callback = (err) -> throw err

	options = _.defaults options or {}, 
		region: nconf.get("ELOPHANT:REGION"),
		apikey: nconf.get("ELOPHANT:APIKEY")

	return [ options, callback ]

fixMethod = (method) ->
	method.replace /_([a-z])/gi, ($...) ->
		return $[1].toUpperCase()

###
API METHODS
###

# "Internal" API methods
module.exports.items = (o, cb) ->
	[o, cb] = buildOptionsCallback o, cb
	url = buildURL null, o.apikey, "items"
	callAPI url, cb

module.exports.champions = (o, cb) ->
	[o, cb] = buildOptionsCallback o, cb
	url = buildURL null, o.apikey, "champions"
	callAPI url, cb

# API methods that only require one argument
_.each [ "summoner", "mastery_pages", "rune_pages", "recent_games", "leagues", "summoner_team_info", "in_progress_game_info", "team", "find_team" ], (method) ->
	fnc = (arg, o, cb) ->
		[o, cb] = buildOptionsCallback o, cb
		url = buildURL o.region, o.apikey, method, arg
		callAPI url, cb

	module.exports[method] = fnc

# Weird API Methods
module.exports.summoner = (sid, o, cb) ->
	[o, cb] = buildOptionsCallback o, cb
	_.defaults o, { complex: false }

	if o.complex
		callback = (err, data) ->
			if err then cb(err)
			else cb(null, new Summoner(data))
	else callback = cb

	url = buildURL o.region, o.apikey, "summoner", sid
	callAPI url, callback

module.exports.ranked_stats = (aid, season, o, cb) ->
	if _.isObject(season) then [cb, o, season] = [o, season, null]

	[o, cb] = buildOptionsCallback o, cb
	url = buildURL o.region, o.apikey, "ranked_stats", aid, season
	callAPI url, cb

module.exports.summoner_names = (ids, o, cb) ->
	if _.isArray(ids) then ids = ids.join(",")
	if _.isNumber(ids) then ids = ids.toString(10)
	unless _.isString(ids) then throw new Error("Expecting a string, number or array for summonerIds.")

	[o, cb] = buildOptionsCallback o, cb
	_.defaults o, { complex: false }

	if o.complex
		callback = (err, data) ->
			if err then cb(err)
			else if _.isArray(data)
				async.map data, ((name, acb) ->
					S = new Summoner(name)
					acb = _.once acb
					S.once "ready", () -> acb null, S
					S.once "error", (err) -> acb err
				), (err, summoners) ->
					if err then cb(err)
					else cb null, summoners
			else cb null, []
	else callback = cb

	url = buildURL o.region, o.apikey, "summoner_names", ids
	url = url.replace "%2C", ","
	
	callAPI url, callback

module.exports.team_end_of_game_stats = (tid, gid, o, cb) ->
	[o, cb] = buildOptionsCallback o, cb
	url = buildURL o.region, o.apikey, "team", tid, "end_of_game_stats", gid
	callAPI url, cb

module.exports.team_ranked_stats = (tid, o, cb) ->
	[o, cb] = buildOptionsCallback o, cb
	url = buildURL o.region, o.apikey, "team", tid, "ranked_stats"
	callAPI url, cb

# Fix methods names
_.each module.exports, (m, n) ->
	jsmn = fixMethod n
	if jsmn isnt n then module.exports[jsmn] = m

###

All API URLS :

http://api.elophant.com/v2/items
http://api.elophant.com/v2/champions
http://api.elophant.com/v2/<region>/summoner/<summonerName>
http://api.elophant.com/v2/<region>/mastery_pages/<summonerId>
http://api.elophant.com/v2/<region>/rune_pages/<summonerId>
http://api.elophant.com/v2/<region>/recent_games/<accountId>
http://api.elophant.com/v2/<region>/summoner_names/<summonerIds>
http://api.elophant.com/v2/<region>/leagues/<summonerId>
http://api.elophant.com/v2/<region>/ranked_stats/<accountId>
http://api.elophant.com/v2/<region>/summoner_team_info/<summonerId>
http://api.elophant.com/v2/<region>/in_progress_game_info/<summonerName>
http://api.elophant.com/v2/<region>/team/<teamId>
http://api.elophant.com/v2/<region>/find_team/<tagOrName>
http://api.elophant.com/v2/<region>/team/<teamId>/end_of_game_stats/<gameId>
http://api.elophant.com/v2/<region>/team/<teamId>/ranked_stats

###