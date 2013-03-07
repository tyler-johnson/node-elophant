// Load Nconf first
var nconf = require('nconf');
nconf.argv()
	.env()
	.defaults({
		ELOPHANT: {
			REGION: "na",
			APIKEY: "kpShkaAKcz722f9SCowm"
		}
	});

// Then everything else
var api = require("./lib/api"),
	Summoner = require("./lib/summoner");

api.summoner("appleifreak", { complex: true }, function(err, summoner) {
	console.log(summoner);
});

/*api.summonerNames([ 22452772, 22519058 ], { complex: true }, function(err, summoners) {
	summoners.forEach(function(summoner) {
		console.log(summoner);
	});
});*/

/*var fuo213 = new Summoner("fuo213");
fuo213.on("ready", function() {
	console.log(fuo213);
});

fuo213.on("error", function(err) {
	console.error(err);
});*/

/*var url = api.buildURL(null, "kpShkaAKcz722f9SCowm", "champions");

console.log(url);*/

/*api.callAPI(url, function(err, data) {
	if (err) console.error(err);
	else console.log(data);
});*/