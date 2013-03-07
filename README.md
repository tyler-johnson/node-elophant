# Node-Elophant API Library

Library for connecting to [Elopant's API](http://elophant.com/developers). Documentation and more details to come when it's finished.

## Examples

Setting up. Second argument is an `options` object and is optional. The region defaults to `na`.

``` js
	var elophant = require("elophant")("SECRET_APIKEY", { region: "na" });
```

All of the api methods at your fingertips.

``` js
	elophant.masteryPages(22452772, function(err, data) {
		if (err) console.error(err);
		else console.log(data);
	});
```

Retrieve multiple summoners by summonerId. Option `complex: true` will force the callback to return an array `Summoner` objects instead of an array of summoner names. You can use the `complex` option on the method `api.summoner()` in the same manner.

``` js
	elophant.summonerNames([ 22452772, 22519058 ], { complex: true }, function(err, summoners) {
		summoners.forEach(function(summoner) {
			console.log(summoner.name);
		});
	});
```

Create new `Summoner` object by the summoner's name. Captures two events: `ready` when the base info has loaded and `error` if the object ever hits an error.

``` js
	var fuo213 = new (elophant.Summoner)("fuo213");
	fuo213.on("ready", function() {
		fuo213.leagues(function(data) {
			console.log(data);
		});
	});

	fuo213.on("error", function(err) {
		console.error(err);
	});
```

Custom API call because why not.

``` js
	var url = elophant.buildURL("na", "SECRET_APIKEY", "summoner", "fuo213");
	elophant.callAPI(url, function(err, data) {
		if (err) console.error(err);
		else console.log(data);
	});
```