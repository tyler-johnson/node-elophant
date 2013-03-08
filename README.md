# Node-Elophant API Library

Library for connecting to [Elopant's API](http://elophant.com/developers). Documentation and more details to come when it's finished.

## Examples

Setting up. Second argument is an `options` object and is optional. The region defaults to `na`.

``` js
var elophant = require("elophant")("SECRET_APIKEY", { region: "na" });
```

Every one of the [Elophant api methods](http://elophant.com/developers/docs) at your fingertips. FYI: `elophant.masteryPages() === elophant.mastery_pages()`.

``` js
elophant.masteryPages(22452772, function(err, data) {
	if (err) console.error(err);
	else console.log(data);
});
```

Create new `Summoner` object by the summoner's name. Captures two events: `ready` when the base info has loaded and `error` if the object hits an error during load.

``` js
var fuo213 = new (elophant.Summoner)("fuo213");

fuo213.on("ready", function() {
	fuo213.leagues(function(err, data) {
		if (err) console.log(err.stack);
		else console.log(data);
	});
});

fuo213.on("error", function(err) {
	console.error(err);
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

Create a new `Team` object, similar to `Summoner`. The option `tagOrName` tells the constructor that the first argument is a tag or name of a team and not an ID.

``` js
var willbus = new (elophant.Team)("nayy", { tagOrName: true });

willbus.on("ready", function() {
	willbus.rankedStats(function(err, data) {
		console.log(err, data);
	});
});

willbus.on("error", function(err) {
	console.error(err);
});
```

All together now. Get `Summoner` and then get the first `Team` and get that team's ranked stats.

``` js
var fuo213 = new (elophant.Summoner)("fuo213");

fuo213.on("ready", function() {
	fuo213.summonerTeamInfo(true, function(err, teams) {
		if (err) console.log(err.stack);
		else teams[0].rankedStats(function(err, data) {
			if (err) console.log(err.stack);
			else console.log(data);
		});
	});
});

fuo213.on("error", function(err) {
	console.error(err);
});
````

Custom API call because why not.

``` js
var url = elophant.buildURL("na", "SECRET_APIKEY", "summoner", "fuo213");

elophant.callAPI(url, function(err, data) {
	if (err) console.error(err);
	else console.log(data);
});
```