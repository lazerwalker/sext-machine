Twilio = require 'twilio'
Express = require 'express'
SightengineClient = require 'nudity-filter'

TwilioSID = process.env.TWILIO_SID
TwilioAuthToken = process.env.TWILIO_AUTHTOKEN
SightEngineUser = process.env.SIGHTENGINE_USER
SightEngineSecret = process.env.SIGHTENGINE_SECRET

Sightengine = new SightengineClient(SightEngineUser, SightEngineSecret)

app = Express()

handleImage = (imageURL, hasOthers=false, opts={}) ->
    {to, from} = opts

    client = Twilio(TwilioSID, TwilioAuthToken)

    Sightengine.checkNudityForURL imageURL, (error, result) ->
        body = ""
        if error?
            body = "Uh, something weird happened. Try again?"
        else if result.result
            body = "I'm #{result.confidence}% turned on."
        else
            body = "I'm not turned on at all."

        console.log(result)
        sms = client.sms.messages.create { to, from, body }

        if hasOthers
            body = "(I saw you sent multiple photos, but I can only be turned on by one at a time. Resend the others?)"
            client.sms.messages.create {to, from, body}


app.get '/sms', (req, res) ->
    console.log req.query

    to = req.query.From
    from = req.query.To

    unless to?
        res.status(500).send("An error has occured")
        return

    image = req.query["MediaUrl0"]
    if image?
        hasOthers = req.query["MediaUrl1"]?
        handleImage(image, hasOthers, {to, from})
    else
        client.sms.messages.create {to, from, body: "You didn't send me a photo!"}

app.listen process.env.PORT || 3000
console.log "Listening on #{process.env.PORT || 3000}"