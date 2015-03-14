Twilio = require 'twilio'
Express = require 'express'
SightengineClient = require 'nudity-filter'

TwilioSID = process.env.TWILIO_SID
TwilioAuthToken = process.env.TWILIO_AUTHTOKEN
SightEngineUser = process.env.SIGHTENGINE_USER
SightEngineSecret = process.env.SIGHTENGINE_SECRET

Sightengine = new SightengineClient(SightEngineUser, SightEngineSecret)

app = Express()

app.get '/sms', (req, res) ->
    console.log req.query

    to = req.query.From
    from = req.query.To

    client = Twilio(TwilioSID, TwilioAuthToken)

    if req.query["MediaUrl0"]?
        Sightengine.checkNudityForURL req.query["MediaUrl0"], (error, result) ->
            body = ""
            if error?
                body = "Uh, something weird happened. Try again?"
            else if result.result
                body = "I'm #{result.confidence}% turned on."
            else
                body = "I'm not turned on at all."

            console.log(result)
            sms = client.sms.messages.create { to, from, body }

            if req.query["MediaUrl1"]?
                body = "(I saw you sent multiple photos, but I can only be turned on by one at a time. Resend the others?)"
                client.sms.messages.create {to, from, body}
    else if to?
        client.sms.messages.create {to, from, body: "You didn't send me a photo!"}
    else
        res.status(500).send("An error has occured")

app.listen process.env.PORT || 3000
console.log "Listening on #{process.env.PORT || 3000}"