events = require("events")
util = require("util")
request = require("request")
Url = require("url")
communications = require("./communication")

class Site extends events.EventEmitter
  constructor: (config) ->
    events.EventEmitter.call this
    @config = config
    @name = config.name
    @type = config.type
    @url = config.url
    @users = config.users
    @content = (if config.content?.length > 0 then config.content else null)
    @interval = config.interval
    @timeout = config.timeout
    @lastRun = 0
    @down = false
    @previousDown = true

  wasDown: -> @previousDown
  isDown: -> @down
  requiresCheck: ->
    return true if (@lastRun + (@interval * 1000)) < new Date().getTime()
    false
  check: (callback) ->
    @request (stats) =>
      @previousDown = @down
      if stats.statusCode isnt 304 and (stats.statusCode < 200 or stats.statusCode > 299)
        @down = true
        stats.notes = "A non 304 or 2XX status code"
      else if stats.contentMatched is false
        @down = true
      else
        @down = false
      callback stats
  
  notify_users: (stats, storage) =>
    if @isDown() is @wasDown()
      @users.forEach (user) ->
        user.contact_methods.forEach (communicationMethod) ->
          commsClass = communications.findByType(communicationMethod.type)
          comms = new commsClass(
            username: user.username,
            communicationMethod,
            config
          )
          if comms.isAllowed()
            comms.send up_down, site, stats, (success, error) ->
              if success
                storage.logCommunicationSuccess site, comms
              else
                storage.logCommunicationFailure site, comms, error
    else
      storage.logFalseAlarm site

  request: (callback) ->
    @lastRun = new Date().getTime()
    stats =
      startTime: new Date().getTime()
      connectTime: 0
      responseTime: 0
      connectTimeout: false
      connectFailed: false
      contentMatched: null
      request: null
      response: null
      body: null
      statusCode: null
      notes: null

    url = Url.parse(@url)
  
    headers =
      Host: url.host + ":" + url.port
      "User-Agent": "coffee-site-monitor/0.0.1"

    request(
      {
        url: url
        headers: headers
        timeout: @timeout * 1000
      },
      (err, resp, body) =>
        if err
          stats.connectFailed = true
          callback stats
        else if resp
          stats.response = resp
          stats.statusCode = resp.statusCode
          stats.connectTime = (new Date().getTime() - stats.startTime) / 1000
          stats.body = body
          stats.responseTime = (new Date().getTime() - stats.startTime) / 1000
          if @content isnt null
            if stats.body.indexOf(@content) >= 0
              stats.contentMatched = true
            else
              stats.contentMatched = false
              stats.notes = "The site content did not contain the string: \"" + @content + "\""
              console.log @content
              console.log 'not found in:'
              console.log stats.body
          callback stats
      )

module.exports = Site


