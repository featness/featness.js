###
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
###

root = exports ? window

((window, undefined_) ->
  JSONP = (url, data, method, callback) ->

    #Set the defaults
    url = url or ""
    data = data or {}
    method = method or ""
    callback = callback or ->


    #Gets all the keys that belong
    #to an object
    getKeys = (obj) ->
      keys = []
      for key of obj
        keys.push key  if obj.hasOwnProperty(key)
      keys


    #Turn the data object into a query string.
    #Add check to see if the second parameter is indeed
    #a data object. If not, keep the default behaviour
    if typeof data is "object"
      queryString = ""
      keys = getKeys(data)
      i = 0

      while i < keys.length
        queryString += encodeURIComponent(keys[i]) + "=" + encodeURIComponent(data[keys[i]])
        queryString += "&"  unless i is keys.length - 1
        i++
      url += "?" + queryString
    else if typeof data is "function"
      method = data
      callback = method

    #If no method was set and they used the callback param in place of
    #the method param instead, we say method is callback and set a
    #default method of "callback"
    if typeof method is "function"
      callback = method
      method = "callback"

    #Check to see if we have Date.now available, if not shim it for older browsers
    unless Date.now
      Date.now = ->
        new Date().getTime()

    #Use timestamp + a random factor to account for a lot of requests in a short time
    #e.g. jsonp1394571775161
    timestamp = Date.now()
    generatedFunction = "jsonp" + Math.round(timestamp + Math.random() * 1000001)

    #Generate the temp JSONP function using the name above
    #First, call the function the user defined in the callback param [callback(json)]
    #Then delete the generated function from the window [delete window[generatedFunction]]
    window[generatedFunction] = (json) ->
      callback json
      delete window[generatedFunction]

      return


    #Check if the user set their own params, and if not add a ? to start a list of params
    #If in fact they did we add a & to add onto the params
    #example1: url = http://url.com THEN http://url.com?callback=X
    #example2: url = http://url.com?example=param THEN http://url.com?example=param&callback=X
    if url.indexOf("?") is -1
      url = url + "?"
    else
      url = url + "&"

    #This generates the <script> tag
    jsonpScript = document.createElement("script")
    jsonpScript.setAttribute "src", url + method + "=" + generatedFunction
    document.getElementsByTagName("head")[0].appendChild jsonpScript
    return

  window.JSONP = JSONP
  return
) root
