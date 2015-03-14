SightengineClient = require ('nudity-filter')

Sightengine = new SightengineClient(process.env.SIGHTENGINE_USER, process.env.SIGHTENGINE_SECRET)
console.log "About to hit internet", Sightengine
Sightengine.checkNudityForFile "./laura.jpg", (error, result) ->
  if error? then console.dir(error)
  else console.log(result)
