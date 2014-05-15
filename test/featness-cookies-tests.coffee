chai = require 'chai'
sinon = require 'sinon'

{Cookies, CookiesClass} = require '../src/featness.cookies'

chai.should()
expect = chai.expect

document = null

describe 'featness-cookies', ->
  it 'should be created with document mock', ->
    mock = {}
    cookies = new CookiesClass(mock)
    expect(cookies.document).to.equal(mock)

  it 'should be able to read a non-existent cookie', ->
    document = {
      cookie: ''
    }
    cookies = new CookiesClass(document)
    expect(cookies.getItem('invalid-key')).to.equal(null)

  it 'should be able to read a cookie', ->
    document = {
      cookie: 'valid-key=dN612300=;other-key=123i12i312'
    }
    cookies = new CookiesClass(document)
    expect(cookies.getItem('valid-key')).to.equal('dN612300=')
    expect(cookies.getItem('other-key')).to.equal('123i12i312')
