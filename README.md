# Node-Elophant API Library

Library for connecting to [Elopant's API](http://elophant.com/developers) and Riot's League of Legends game data.

## Install

``` bash
npm install elophant
```

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

## API Documentation

### Basic Elophant API

The following methods are standardized to [Elophant's API](http://elophant.com/developers/docs). You can call these methods by their traditional name (ie `rune_pages`) or by the JS standard name (ie `runePages`). All `callback`s take two arguments, `error` and `data`, where `data` is the parsed Elophant data. `options` is an optional Javascript object.

#### Options

* `region` : Uses this region for the call instead of the original one passed.
* `apikey` : Uses this apikey for the call instead of the original one passed.
* `complex`: Only available on a few methods. Essentially forces the callback to create either `Summoner` or `Team` objects on return

#### Methods

* `summoner(summonerName, [ options, ] [ callback ])` : <http://elophant.com/developers/docs/summoner>
* `masteryPages(summonerId, [ options, ] [ callback ])` : <http://elophant.com/developers/docs/mastery_pages>
* `runePages(summonerId, [ options, ] [ callback ])` : <http://elophant.com/developers/docs/rune_pages>
* `recentGames(accountId, [ options, ] [ callback ])` : <http://elophant.com/developers/docs/recent_games>
* `summonerNames(summonerIds, [ options, ] [ callback ])` : Accepts array, string or number for `summonerIds`. <http://elophant.com/developers/docs/summoner_names>
* `leagues(summonerId, callback)` : <http://elophant.com/developers/docs/leagues>
* `rankedStats(accountId, [ season, ] [ options, ] [ callback ])` : <http://elophant.com/developers/docs/ranked_stats>
* `summonerTeamInfo(summonerId, [ options, ] [ callback ])` : <http://elophant.com/developers/docs/summoner_team_info>
* `inProgressGameInfo(summonerName, [ options, ] [ callback ])` : <http://elophant.com/developers/docs/in_progress_game_info>
* `team(teamId, [ options, ] [ callback ])` : <http://elophant.com/developers/docs/team>
* `findTeam(tagOrName, [ options, ] [ callback ])` : <http://elophant.com/developers/docs/find_team>
* `teamEndOfGameStats(teamId, gameId, [ options, ] [ callback ])` : <http://elophant.com/developers/docs/team_end_of_game_stats>
* `teamRankedStats(teamId, [ options, ] [ callback ])` : <http://elophant.com/developers/docs/team_ranked_stats>

### Summoner Class

The `Summoner` class is convienent way to deal with summoner data. The constructor makes one API call to retrieve basic data (like `summonerId`) and then uses that to make additional calls. The base class is attached as `elophant.Summoner`. See the examples for proper usage.

``` js
new (elophant.Summoner)(name | summonerId | data [, options ] );
```

#### Options

* `cache`, Default: `true` : Cache results on subsequent call. Prevents too many api calls from being  made.
* `region` : Uses this region for the call instead of the original one passed.
* `apikey` : Uses this apikey for the call instead of the original one passed.

#### Methods

* `masteryPages([ callback ])`
* `runePages([ callback ])`
* `recentGames([ callback ])`
* `leagues([ callback ])`
* `summonerTeamInfo([ complex ] [, callback ])` : Set `complex` to `true` for `Team` objects instead of basic objects.
* `inProgressGameInfo([ callback ])`
* `rankedStats([ season ] [, callback ])`

### Team Class

The `Team` class is convienent way to deal with team data. The constructor makes one API call to retrieve basic data (like `teamId`) and then uses that to make additional calls. The base class is attached as `Team`. See the examples for proper usage.

``` js
new (elophant.Team)(teamId | tagOrName | data [, options ] );
```

#### Options

* `tagOrName`, Default: `false` : Tells the contructor that the first argument passed is a team tag or name and not a teamId.
* `cache`, Default: `true` : Cache results on subsequent call. Prevents too many api calls from being  made.
* `region` : Uses this region for the call instead of the original one passed.
* `apikey` : Uses this apikey for the call instead of the original one passed.

#### Methods

* `endOfGameStats(gameId, [ callback ])`
* `rankedStats([ callback ])` : Team ranked stats (not summoner ranked stats)

### Other Methods

These are some additional methods, attached directly to `elophant`, to help out with API calls.

* `buildURL(region, apikey [, args... ])` : Build an API URL from the `region`, `apikey` and the rest of the parameters. Pass null for any of the arguments to leave out.
* `callAPI(url, callback)` : Make an API call and parse response JSON for `data` or `error`.