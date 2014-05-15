#:: cookies.js ::

#A complete cookies reader/writer framework with full unicode support.

#https://developer.mozilla.org/en-US/docs/DOM/document.cookie

#This framework is released under the GNU Public License, version 3 or later.
#http://www.gnu.org/licenses/gpl-3.0-standalone.html

class Cookies
  constructor: (@document) ->

  getItem: (sKey) ->
    decodeURIComponent(@document.cookie.replace(new RegExp("(?:(?:^|.*;)\\s*" + encodeURIComponent(sKey).replace(/[\-\.\+\*]/g, "\\$&") + "\\s*\\=\\s*([^;]*).*$)|^.*$"), "$1")) or null

root = exports ? window
root.Cookies = new Cookies(document? and document or null)
root.CookiesClass = Cookies
