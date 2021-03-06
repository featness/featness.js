#featness = new Featness(
  #apiUrl: 'http://local.featness.com:2368',
  #userId: (resolve) ->
    #resolve(cookie)
#)

#featness.addFact "cadun.user", (resolve) ->
  #resolve(cookie)

#featness.addFact "facebook.authenticated", (resolve) ->
  #async(callback(resolve))

#featness.addFact "google.authenticated", (resolve) ->
  #async(callback(resolve))

#featness.isEnabled "0afb6b43", (context) ->
  #console.log(context)

# a) addFacts (push to queue)
# b) setTimeout(->
#     addFactQueue.AwaitAll(->
#       processIsEnabledQueue()
#     , 1000, ->
#       processIsEnabledQueue()
#     ), 150) # timeout needed to allow all addFacts calls to proceed
# c) isEnableds (push to queue)

class Featness
  constructor: (config, @cookies, @jsonp, @queueClass) ->
    @options =
      isEnabledTimeout: 500

    for key, val of config
      @options[key] = val

    @cookies = root.Cookies unless @cookies?
    @jsonp = root.JSONP unless @jsonp?
    @openFacts = 0
    if not @queueClass?
      @queueClass = root.queue

    @_resolveUserId()
    @_resolveSessionId()

    @_factQ = queueClass()
    @_featQ = queueClass(
      autoStart: false
    )

    @_startFeatQ()

  _resolveUserId: =>
    @options.userId(@_setUserId)

  _resolveSessionId: =>
    @sessionId = @cookies.getItem('featSID')

  _setUserId: (value) =>
    @userId = value

  _resolveFact: (key) ->
    return (value) =>
      @_sendFact(key, value)

  _sendFact: (key, value) =>
    @jsonp(
      "#{@options.apiUrl}/add-fact?userId=#{ @userId }&sessionId=#{ @sessionId }&key=#{ key }&value=#{ value }",
      (result) =>
    )

  _startFeatQ: ->
    setTimeout @_featQ.start, @options.isEnabledTimeout

  addFact: (key, valueFunc) ->
    @_factQ.defer valueFunc, @_resolveFact(key)

  _sendIsEnabled: (key, callback) =>
    @jsonp(
      "#{@options.apiUrl}/is-enabled?userId=#{ @userId }&sessionId=#{ @sessionId }&key=#{ key }",
      (result) =>
        callback(result)
    )

  isEnabled: (key, callback) ->
    @_featQ.defer @_sendIsEnabled, key, callback

root = exports ? window
root.Featness = Featness
