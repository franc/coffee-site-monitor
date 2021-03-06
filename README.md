[![build status](https://secure.travis-ci.org/franc/coffee-site-monitor.png)](http://travis-ci.org/franc/coffee-site-monitor)
#Coffee Site Monitor

based off [Node Site Monitor](https://git@github.com/hootware/node-site-json.git)

A simple node server that will check the status of any number of websites and alert any number of users in different ways.

##Why not just use Node Site Monitor?

Node Site Monitor has a slightly different philosophy to what I hold: users should be tightly related to sites. A site should have its own array of users, and those users may want different communication channels for different sites. 

redirects should also be followed so as to verify content that would actually be displayed in the browser.

I also wanted to do as much as possible in CoffeeScript. In the project's future everything will be CoffeeScript and it will focus on getting site config from MongoDB. There will be a central deployment that will communicate with other instances that do the response testing, and take care of communication with users centrally.

##Install

###NPM

    npm install coffee-site-monitor
    
###Manual

You need to download the code and also install the nodemailer library as this is used for e-mail alerts


##Usage

Easy peasy! It will load the config when started and will just keep running. If you want to change the config, you need to restart the application.

    coffee site-monitor

##Check types

The different ways that are checked to see the status of a site

*   Check if host is reachable
*   Check HTTP status code
*   Check for connect timeouts
*   Check to see if text on the page matches what is expected


##Alert types

The different ways of sending alerts to users. Users can have multiple methods, each with different "availability windows"

*   E-mail:
      *   GMail is the only service available at the moment
      *   Other providers/SMTP setup coming soon
*   (future) Twitter DM (free SMS!)
*   (future) Twitter mention
*   (future) Custom POST request
*   Make your own... just extend the base communication class lib/communication/base.js


##Storage types

The different ways to store the site check data and what

*   stdout (console.log)
*   (future) file
*   (future) MongoDB
*   Make your own... just extend the base communication class lib/storage/base.js


##Setup
This is all done in a simple config file. As long as you match the format in the config.json example it will work fine.
The arrays in the config don't have any soft limits, so the only limits will be in node or hardware. Let us know if you have any issues.
If you want to change the config, you need to restart the application.

Copy the `sample-config.json` and rename to `config.json` then start the application.