// Load Nconf first
var nconf = require('nconf'),
	_ = require('underscore');

nconf.env();
nconf.use('memory');

// Then everything else
var api = require("./lib/api");

api.Summoner = require("./lib/summoner");

module.exports = function (apikey, options) {
	options = _.defaults(options || {}, { REGION: "na", APIKEY: null })
	if (apikey) options.APIKEY = apikey;
	nconf.set("ELOPHANT", options);
	
	return api;
}