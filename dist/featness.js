(function() {
  var slice = [].slice;

  function queue(parallelism, options) {
    if (options == null) {
      if (parallelism !== null && typeof parallelism === 'object') {
        options = parallelism;
        parallelism = null;
      } else {
        options = {
          autoStart: true
        }
      }
    }

    var q,
        autoStart = options.autoStart == null ? true : options.autoStart,
        tasks = [],
        started = 0, // number of tasks that have been started (and perhaps finished)
        active = 0, // number of tasks currently being executed (started but not finished)
        remaining = 0, // number of tasks not yet finished
        popping, // inside a synchronous task callback?
        error = null,
        await = noop,
        queueStarted = autoStart,
        all;

    if (!parallelism) parallelism = Infinity;

    function pop() {
      while (popping = started < tasks.length && active < parallelism) {
        var i = started++,
            t = tasks[i],
            a = slice.call(t, 1);
        a.push(callback(i));
        ++active;
        t[0].apply(null, a);
      }
    }

    function callback(i) {
      return function(e, r) {
        --active;
        if (error != null) return;
        if (e != null) {
          error = e; // ignore new tasks and squelch active callbacks
          started = remaining = NaN; // stop queued tasks from starting
          notify();
        } else {
          tasks[i] = r;
          if (--remaining) popping || pop();
          else notify();
        }
      };
    }

    function notify() {
      if (error != null) await(error);
      else if (all) await(error, tasks);
      else await.apply(null, [error].concat(tasks));
    }

    return q = {
      defer: function() {
        if (!error) {
          tasks.push(arguments);
          ++remaining;
          if (queueStarted) {
            pop();
          }
        }
        return q;
      },
      await: function(f) {
        await = f;
        all = false;
        if (!remaining) notify();
        return q;
      },
      awaitAll: function(f) {
        await = f;
        all = true;
        if (!remaining) notify();
        return q;
      },
      start: function() {
        if (queueStarted) {
          throw "Can't start queue twice.";
        }
        queueStarted = true;
        pop();
        return q;
      }
    };
  }

  function noop() {}

  queue.version = "1.0.9";
  if (typeof define === "function" && define.amd) define(function() { return queue; });
  else if (typeof module === "object" && module.exports) module.exports = queue;
  else this.queue = queue;
})();
;(function() {
  var Featness, root,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  Featness = (function() {
    function Featness(config, cookies, jsonp, queueClass) {
      var key, val;
      this.cookies = cookies;
      this.jsonp = jsonp;
      this.queueClass = queueClass;
      this._sendIsEnabled = __bind(this._sendIsEnabled, this);
      this._sendFact = __bind(this._sendFact, this);
      this._setUserId = __bind(this._setUserId, this);
      this._resolveSessionId = __bind(this._resolveSessionId, this);
      this._resolveUserId = __bind(this._resolveUserId, this);
      this.options = {
        isEnabledTimeout: 500
      };
      for (key in config) {
        val = config[key];
        this.options[key] = val;
      }
      if (this.cookies == null) {
        this.cookies = root.Cookies;
      }
      if (this.jsonp == null) {
        this.jsonp = root.JSONP;
      }
      this.openFacts = 0;
      if (this.queueClass == null) {
        this.queueClass = root.queue;
      }
      this._resolveUserId();
      this._resolveSessionId();
      this._factQ = queueClass();
      this._featQ = queueClass({
        autoStart: false
      });
      this._startFeatQ();
    }

    Featness.prototype._resolveUserId = function() {
      return this.options.userId(this._setUserId);
    };

    Featness.prototype._resolveSessionId = function() {
      return this.sessionId = this.cookies.getItem('featSID');
    };

    Featness.prototype._setUserId = function(value) {
      return this.userId = value;
    };

    Featness.prototype._resolveFact = function(key) {
      return (function(_this) {
        return function(value) {
          return _this._sendFact(key, value);
        };
      })(this);
    };

    Featness.prototype._sendFact = function(key, value) {
      return this.jsonp("" + this.options.apiUrl + "/fact?userId=" + this.userId + "&sessionId=" + this.sessionId + "&key=" + key + "&value=" + value, (function(_this) {
        return function(result) {};
      })(this));
    };

    Featness.prototype._startFeatQ = function() {
      return setTimeout(this._featQ.start, this.options.isEnabledTimeout);
    };

    Featness.prototype.addFact = function(key, valueFunc) {
      return this._factQ.defer(valueFunc, this._resolveFact(key));
    };

    Featness.prototype._sendIsEnabled = function(key, callback) {
      return this.jsonp("" + this.options.apiUrl + "/is-enabled?userId=" + this.userId + "&sessionId=" + this.sessionId + "&key=" + key, (function(_this) {
        return function(result) {
          return callback(result);
        };
      })(this));
    };

    Featness.prototype.isEnabled = function(key, callback) {
      return this._featQ.defer(this._sendIsEnabled, key, callback);
    };

    return Featness;

  })();

  root = typeof exports !== "undefined" && exports !== null ? exports : window;

  root.Featness = Featness;

}).call(this);

(function() {
  var Cookies, root;

  Cookies = (function() {
    function Cookies(document) {
      this.document = document;
    }

    Cookies.prototype.getItem = function(sKey) {
      return decodeURIComponent(this.document.cookie.replace(new RegExp("(?:(?:^|.*;)\\s*" + encodeURIComponent(sKey).replace(/[\-\.\+\*]/g, "\\$&") + "\\s*\\=\\s*([^;]*).*$)|^.*$"), "$1")) || null;
    };

    return Cookies;

  })();

  root = typeof exports !== "undefined" && exports !== null ? exports : window;

  root.Cookies = new Cookies((typeof document !== "undefined" && document !== null) && document || null);

  root.CookiesClass = Cookies;

}).call(this);


/*
ADAPTED FROM https://github.com/OscarGodson/JSONP

JSONP sets up and allows you to execute a JSONP request
@param {String} url  The URL you are requesting with the JSON data
@param {Object} data The Data object you want to generate the URL params from
@param {String} method  The method name for the callback function. Defaults to callback (for example, flickr's is "jsoncallback")
@param {Function} callback  The callback you want to execute as an anonymous function. The first parameter of the anonymous callback function is the JSON

@example
JSONP('http://twitter.com/users/oscargodson.json',function(json){
document.getElementById('avatar').innerHTML = '<p>Twitter Pic:</p><img src="'+json.profile_image_url+'">';
});

@example
JSONP('http://api.flickr.com/services/feeds/photos_public.gne',{'id':'12389944@N03','format':'json'},'jsoncallback',function(json){
document.getElementById('flickrPic').innerHTML = '<p>Flickr Pic:</p><img src="'+json.items[0].media.m+'">';
});

@example
JSONP('http://graph.facebook.com/FacebookDevelopers', 'callback', function(json){
document.getElementById('facebook').innerHTML = json.about;
});
 */

(function() {
  var root;

  root = typeof exports !== "undefined" && exports !== null ? exports : window;

  (function(window, undefined_) {
    var JSONP;
    JSONP = function(url, data, method, callback) {
      var generatedFunction, getKeys, i, jsonpScript, keys, queryString, timestamp;
      url = url || "";
      data = data || {};
      method = method || "";
      callback = callback || function() {};
      getKeys = function(obj) {
        var key, keys;
        keys = [];
        for (key in obj) {
          if (obj.hasOwnProperty(key)) {
            keys.push(key);
          }
        }
        return keys;
      };
      if (typeof data === "object") {
        queryString = "";
        keys = getKeys(data);
        i = 0;
        while (i < keys.length) {
          queryString += encodeURIComponent(keys[i]) + "=" + encodeURIComponent(data[keys[i]]);
          if (i !== keys.length - 1) {
            queryString += "&";
          }
          i++;
        }
        url += "?" + queryString;
      } else if (typeof data === "function") {
        method = data;
        callback = method;
      }
      if (typeof method === "function") {
        callback = method;
        method = "callback";
      }
      if (!Date.now) {
        Date.now = function() {
          return new Date().getTime();
        };
      }
      timestamp = Date.now();
      generatedFunction = "jsonp" + Math.round(timestamp + Math.random() * 1000001);
      window[generatedFunction] = function(json) {
        callback(json);
        delete window[generatedFunction];
      };
      if (url.indexOf("?") === -1) {
        url = url + "?";
      } else {
        url = url + "&";
      }
      jsonpScript = document.createElement("script");
      jsonpScript.setAttribute("src", url + method + "=" + generatedFunction);
      document.getElementsByTagName("head")[0].appendChild(jsonpScript);
    };
    window.JSONP = JSONP;
  })(root);

}).call(this);
