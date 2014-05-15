chai = require 'chai'
sinon = require 'sinon'

{Featness} = require '../src/featness'
{Cookies, CookiesClass} = require '../src/featness.cookies'
{JSONP} = require '../src/featness.jsonp'
queueClass = require '../bower_components/asynqueue/queue'

expect = chai.expect
chai.should()

describe 'featness', ->
  cookiesMock = null
  featness = null

  beforeEach ->
    cookiesMock = new CookiesClass(
      cookie: 'featSID=1234567890;something-else=123948824;'
    )

    featness = new Featness({
      apiUrl: 'http://local.featness.com:2368'
      userId: (resolve) ->
        resolve("user")

      },
      cookiesMock,
      null,
      queueClass
    )

  it 'can create a new instance with options', ->
    expect(featness.options.apiUrl).to.equal('http://local.featness.com:2368')
    expect(featness.userId).to.equal('user')
    expect(featness.sessionId).to.equal('1234567890')

  describe 'sending facts', ->
    jsonpMock = null
    jsonpMockCalls = []

    beforeEach ->
      jsonpMock = (url, callback) ->
        jsonpMockCalls.push([url, callback])
        callback("OK")
      jsonpMockCalls = []

      featness = new Featness({
        apiUrl: 'http://local.featness.com:2368'
        userId: (resolve) ->
          resolve("user")

        },
        cookiesMock,
        jsonpMock,
        queueClass
      )


    it 'can send a new fact', (done) ->
      factUrl = "http://local.featness.com:2368/fact?userId=user&sessionId=1234567890&key=facebook.authenticated&value=true"
      featness.addFact "facebook.authenticated", (resolve) ->
        resolve(true)

        expect(jsonpMockCalls.length).to.equal(1)
        expect(jsonpMockCalls[0][0]).to.equal(factUrl)
        done()
