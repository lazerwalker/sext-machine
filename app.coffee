Twilio = require 'twilio'
Express = require 'express'
SightengineClient = require 'nudity-filter'
Parse = require('parse').Parse;
  
TwilioSID = process.env.TWILIO_SID
TwilioAuthToken = process.env.TWILIO_AUTHTOKEN
TwilioNum = process.env.TWILIO_NUM
SightEngineUser = process.env.SIGHTENGINE_USER
SightEngineSecret = process.env.SIGHTENGINE_SECRET
ParseAppID = process.env.PARSE_APP_ID
ParseKey = process.env.PARSE_KEY

Sightengine = new SightengineClient(SightEngineUser, SightEngineSecret)
Parse.initialize(ParseAppID, ParseKey)

app = Express()

Conversation = Parse.Object.extend "Conversation"
Pic = Parse.Object.extend "Pic"

TwilioClient = Twilio(TwilioSID, TwilioAuthToken)
sendSMS = (to, msg) ->
    TwilioClient.sms.messages.create({to, from:TwilioNum, body:msg})

handleImage = (imageURL, hasOthers=false, conversation) ->
    sender = conversation.get('phone')

    Sightengine.checkNudityForURL imageURL, (error, result) ->
        msg = ""
        if error?
            msg = "Uh, something weird happened. Try again?"
            console.log(error)
            sendSMS(sender, msg)
            return
        else if result.result
            msg = "I'm #{result.confidence}% turned on."
        else
            msg = "I'm not turned on at all."

        console.log(sender, result)

        data =
            url: imageURL
            isNude: result.result
            conversation: conversation
            confidence: result.confidence
        pic = new Pic()
        pic.save(data)

        sendSMS(sender, msg)
        if hasOthers
            msg = "(I saw you sent multiple photos, but I can only be turned on by one at a time. You should resend the others!)"
            sendSMS(sender, msg)



app.get '/sms', (req, res) ->
    fail = -> res.status(500).send("An error has occured")

    sender = req.query.From
    console.log req.query

    unless sender?
        fail()
        return

    processMessage = (conversation) ->
        image = req.query["MediaUrl0"]
        if image?
            hasOthers = req.query["MediaUrl1"]?
            handleImage(image, hasOthers, conversation)
        else
            client = Twilio(TwilioSID, TwilioAuthToken)
            sendSMS(sender, "You didn't send me a photo!")


    query = new Parse.Query(Conversation);
    query.equalTo("phone", sender)
    query.first
      success: (conversation) ->
        if conversation?
            processMessage(conversation)
        else
            conversation = new Conversation()
            conversation.save {phone: sender},
                success: (conversation) ->
                    sendSMS(sender, "how u doin bae? ;)")

      error: (error) ->
        fail()


app.listen process.env.PORT || 3000
console.log "Listening on #{process.env.PORT || 3000}"