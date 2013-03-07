# Node-Elophant API Library

Library for connecting to [Elopant's API](http://elophant.com/developers). Documentation and more details to come when it's finished.

## Examples

All of the api methods at your fingertips.

	api.masterPages(22452772, function(err, data) {
		if (err) console.error(err);
		else console.log(data);
	});

Retrieve multiple summoners by summonerId. Option `complex: true` will force the callback to return an array `Summoner` objects instead of an array of summoner names. You can use the `complex` option on the method `api.summoner()` in the same manner.

	api.summonerNames([ 22452772, 22519058 ], { complex: true }, function(err, summoners) {
		summoners.forEach(function(summoner) {
			console.log(summoner.name);
		});
	});

Create new `Summoner` object by the summoner's name. Captures two events: `ready` when the base info has loaded and `error` if the object ever hits and error.

	var fuo213 = new Summoner("fuo213");
	fuo213.on("ready", function() {
		console.log(fuo213);
	});

	fuo213.on("error", function(err) {
		console.error(err);
	});

Custom API call because why not.

	var url = api.buildURL("na", "SECRET_APIKEY", "summoner", "fuo213");
	api.callAPI(url, function(err, data) {
		if (err) console.error(err);
		else console.log(data);
	});