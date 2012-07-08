events = require('events')
util = require('util')
http = require('http')
Url = require('url')

#Mailer
nodemailer = require('nodemailer')


### 
 * Base communication
 *
 * @param config Object the configuration
 * 
 * @returns Site
###
BaseCommunication = (user, config, baseConfig) ->
	events.EventEmitter.call(this)

	#User
	@user = user
	
	#The config
	@config = config
	
	#The base config
	@baseConfig = baseConfig


#Inherit event emitter
util.inherits(BaseCommunication, events.EventEmitter)

#Export
module.exports = BaseCommunication
					
###
 * Can send
 *
 * @returns void
###
BaseCommunication.prototype.toArray = () ->
	return {
		user: @user,
		config: @config
	}
					
###
 * Can send
 *
 * @returns void
###
BaseCommunication.prototype.isAllowed = () ->
	return true

###
 * Log success
 *
 * @returns void
###
BaseCommunication.prototype.send = (up_down, site, stats, callback) ->
	# send an e-mail
	htmlBody = '<p><strong>Hello ' + @user.username + ',</strong></p>'
	body = 'Hello ' + @config.username + ',' + "\n\n"
	
	#Remove stats
	delete stats.response
	delete stats.request
	
	#Loop through stats
	for key in Object.keys(stats)
		htmlBody += '<li><strong>' + key + '</strong>: ' + stats[key] + '</li>'
		body += key + ': ' + stats[key] + "\n"
	
	htmlBody += '</ul><p>Thanks<br />Your site monitor</p>'
	body += "\nThanks\nYour site monitor"
	
	#Get the transport
	transport = nodemailer.createTransport("SMTP", {
		service: @baseConfig.email.service,
		auth: {
			user: @baseConfig.email.username,
			pass: @baseConfig.email.password
		}
	})
	
	mailOptions = {
		transport: transport,
		from: @baseConfig.email.sender + " <" + @baseConfig.email.sender + ">",
		to: @config.address,
		subject: up_down == 'down' ? site.name + ' is down!' : site.name + ' is up!',
		text: body,
		html: htmlBody
	}

	nodemailer.sendMail(mailOptions, (error) ->
		if error
			callback(false, error)
		else
			callback(true)
	)		

