// Generated by CoffeeScript 1.5.0
(function() {
  var EventEmitter, Team, api, nconf, _,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    __slice = [].slice;

  EventEmitter = require('events').EventEmitter;

  _ = require('underscore');

  api = require("./api");

  nconf = require('nconf');

  Team = (function(_super) {

    __extends(Team, _super);

    function Team(id, options) {
      var _this = this;
      this.options = _.defaults(options || {}, {
        tagOrName: false,
        cache: true,
        region: nconf.get("ELOPHANT:REGION"),
        apikey: nconf.get("ELOPHANT:APIKEY")
      });
      this.cache = {};
      if (_.isString(id)) {
        if (this.options.tagOrName) {
          this._call("find_team", id, function(err, data) {
            if (err) {
              _this.emit("error", err);
            }
            if (data) {
              return _this._init(data);
            }
          });
        } else {
          this._call("team", id, function(err, data) {
            if (err) {
              _this.emit("error", err);
            }
            if (data) {
              return _this._init(data);
            }
          });
        }
      } else if (_.isObject(id)) {
        this._init(id);
      }
    }

    Team.prototype._init = function(data) {
      var _this = this;
      _.each(data, function(v, k) {
        if (!_.has(_this, k)) {
          return _this[k] = v;
        }
      });
      if (_.isObject(this.teamStatSummary)) {
        this.teamId = this.teamStatSummary.teamId.fullId;
      }
      return this.emit("ready");
    };

    Team.prototype._handle = function() {
      var args, cache, cb, method, _i;
      method = arguments[0], args = 3 <= arguments.length ? __slice.call(arguments, 1, _i = arguments.length - 1) : (_i = 1, []), cb = arguments[_i++];
      if (this.options.cache && _.has(this.cache, method)) {
        cache = this.cache[method];
        if (_.isFunction(cb)) {
          return cb(null, cache);
        } else {
          return cache;
        }
      } else {
        return this._call(method, args, cb);
      }
    };

    Team.prototype._call = function() {
      var a, args, callback, cb, method, _i,
        _this = this;
      method = arguments[0], args = 3 <= arguments.length ? __slice.call(arguments, 1, _i = arguments.length - 1) : (_i = 1, []), cb = arguments[_i++];
      callback = function(err, data) {
        if (data && _this.options.cache) {
          _this.cache[method] = data;
        }
        if (_.isFunction(cb)) {
          return cb.apply(null, arguments);
        }
      };
      a = _.chain([
        args, {
          region: this.options.region,
          apikey: this.options.apikey
        }, callback
      ]).flatten().compact().value();
      return api[method].apply(null, a);
    };

    Team.prototype.endOfGameStats = function(gid, cb) {
      return this._handle("team_end_of_game_stats", this.teamId, gid, cb);
    };

    Team.prototype.rankedStats = function(cb) {
      return this._handle("team_ranked_stats", this.teamId, cb);
    };

    return Team;

  })(EventEmitter);

  module.exports = Team;

}).call(this);