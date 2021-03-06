events = require('events')
util = require('util')
http = require('http')
Url = require('url')

### 
 * Base storage
 *
 * @param config Object the configuration
 * 
 * @returns Site
###
BaseStorage = (config) ->
	events.EventEmitter.call(@)
	#The config
	@config = config

#Inherit event emitter
util.inherits(BaseStorage, events.EventEmitter)

#Export
module.exports = BaseStorage

###
 * Log success
 *
 * @returns void
###
BaseStorage.prototype.logSuccess = (site, stats) ->
	#Remove the body, response and request
	delete stats.body
	delete stats.response
	delete stats.request
	@log("[SUCCESS] [" + site.name + "] [" + site.url + "] - " + JSON.stringify(stats))

###
 * Log failure
 *
 * @returns void
###
BaseStorage.prototype.logFailure = (site, stats) ->
	#Remove the body, response and request
	delete stats.body
	delete stats.response
	delete stats.request
	@log("[FAILURE] [" + site.name + "] [" + site.url + "] - " + JSON.stringify(stats))

###
 * Log failure
 *
 * @returns void
###
BaseStorage.prototype.logFalseAlarm = (site) ->
	@log("[FALSE ALARM] [" + site.name + "] [" + site.url + "] - " + JSON.stringify({
		isDown: site.isDown(),
		wasDown: site.wasDown()
	}))

###
 * Log communication success
 *
 * @returns void
###
BaseStorage.prototype.logCommunicationSuccess = (site, communication) ->
	@log("[COMMS][SUCCESS] [" + site.name + "] [" + site.url + "]" + JSON.stringify(communication.toArray()))

###
 * Log failure
 *
 * @returns void
###
BaseStorage.prototype.logCommunicationFailure = (site, communication, error) ->
	@log("[COMMS][FAILURE] [" + site.name + "] [" + site.url + "] - " + JSON.stringify(communication.toArray()) + ' - ' + error.stack)

###
 * Log the message
 *
 * @returns void
###
BaseStorage.prototype.log = (message) ->
	var date = new Date()
	var datedMsg = date.toDateString() + ' ' + date.toTimeString().substr(0, 8)
	console.log(datedMsg + ": " + message)
