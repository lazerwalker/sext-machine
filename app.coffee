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

findUser = (phone, {found, notFound}) ->
    query = new Parse.Query(Conversation);
    query.equalTo("phone", phone)
    query.first
        success: (conversation) ->
            if conversation?
                found(conversation)
            else
                notFound()
createNewUser = (phone, success) ->
    conversation = new Conversation()
    conversation.save {phone}, {success}


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
            msg = "(u sent me more than 1 photo! i can only be turned on by 1 at a tmie. send the others again ;P)"
            sendSMS(sender, msg)



app.get '/sms', (req, res) ->
    fail = -> res.status(500).send("An error has occured")

    sender = req.query.From
    if sender.length > 1 then sender = sender[0]

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
            sendSMS(sender, "u didnt include a photo :(")
            # TODO: Analytics call

    findUser sender,
        found: (conversation) -> processMessage(conversation)
        notFound: () ->
            createNewUser sender, (conversation) ->
                sendSMS(sender, "[OPERATIONS MANUAL: Using complex nudity-detection algorithms, Sext Machine is programmed to feel arousal proportional to the likelihood a photo is X-rated.")
                sendSMS(sender, "Without sending actual explicit photos, arouse the unit by taking and sending pictures with your phone camera that it believes to contain nudity.]")
                sendSMS(sender, "how u doin bae? ;)")

app.listen process.env.PORT || 3000
console.log "Listening on #{process.env.PORT || 3000}"