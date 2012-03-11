fs = require("fs")
util = require("./lib/util")
storages = require("./lib/storage")
Site = require("./lib/site")

config = JSON.parse(fs.readFileSync("./config.json", "utf8"))
baseConfig = {}
for own conf, val of config
  baseConfig[conf] = val unless conf is 'sites'
console.log JSON.stringify baseConfig
sites = []
storage = new (storages.findByType(config.storage.type))
config.sites.forEach (siteConfig) ->
  sites.push new Site(siteConfig, baseConfig)

runChecks = ->
  util.asyncForEach sites, (site) ->
    if site.requiresCheck()
      site.check (stats) ->
        up_down = false
        if site.isDown() and not site.wasDown()
          storage.logFailure site, stats
          up_down = "down"
          site.notify_users(stats, storage, up_down)
        else if not site.isDown() and site.wasDown()
          storage.logSuccess site, stats
          up_down = "up"
        else if site.isDown() and site.wasDown()
          storage.logFailure site, stats
          site.notify_users(stats, storage, up_down)
        else
          storage.logSuccess site, stats
        if up_down isnt false
          setTimeout( => site.check site.notify_users(stats, storage, up_down), 500)

runChecks()
setInterval (->
  runChecks()
), 10 * 1000