Twilio = require 'twilio'
Express = require 'express'
BodyParser = require 'body-parser'
SightengineClient = require 'nudity-filter'

Sightengine = new SightengineClient(process.env.SIGHTENGINE_USER, process.env.SIGHTENGINE_SECRET)

app = Express()

app.get '/sms', (req, res) ->
    console.log req.query

    to = req.query.From
    from = req.query.To

    client = Twilio(process.env.TWILIO_SID, process.env.TWILIO_AUTHTOKEN)

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

    else
        sms = client.sms.messages.create {to, from, body: "You didn't send me a photo!"}

app.listen process.env.PORT || 3000
console.log "Listening on #{process.env.PORT || 3000}"