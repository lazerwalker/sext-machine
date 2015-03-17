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
            msg = "can u send again? error w my prgrmming."
            console.log(error)
            sendSMS(sender, msg)
            return
        else if result.result
            msg = "that pic makes me like #{result.confidence}% turned on rn"
            if result.confidence <= 15
                msg += " :/"
            else if result.confidence >= 60
                msg += ' :)'
            else if result.confidence >= 70
                msg += ' ;)'
            else if result.confidence >= 85
                msg += ' :D :D :D'
        else
            messages = [
                'not hot at all X.X'
                'thats soooo unsexy :/'
                'that doesnt turn me on at all :('
                'wtf is that smh'
                '...seriously? lame.'
                'its like ur not even trying :/'
                'where are the n00ds :('
            ]
            index = Math.floor(Math.random() * messages.length)
            msg = messages[index]

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
            Parse.Analytics.track("uploaded multiple photos")
            msg = "(i can only be turned on by 1 pic at a tmie. send the others again ;P)"
            sendSMS(sender, msg)



app.get '/sms', (req, res) ->
    fail = -> res.status(500).send("An error has occured")

    sender = req.query.From
    if sender.length > 1 then sender = sender[0]

    console.log req.query

    unless sender?
        Parse.Analytics.track("invalid request", "no sender")
        fail()
        return

    processMessage = (conversation) ->
        image = req.query["MediaUrl0"]
        if image?
            if image.length > 1 then image = image[0]
            hasOthers = req.query["MediaUrl1"]?
            handleImage(image, hasOthers, conversation)
        else
            Parse.Analytics.track("no photo")
            sendSMS(sender, "u didnt include a photo :(")
        res.status(200)

    findUser sender,
        found: (conversation) -> processMessage(conversation)
        notFound: () ->
            createNewUser sender, (conversation) ->
                sendSMS(sender, "[OPERATIONS MANUAL: Using nudity-detection algorithms, Sext Machine is programmed to feel arousal relative to the likelihood a photo has inappropriate content.")
                sendSMS(sender, "Trick the unit into being aroused by taking and sending pictures with your phone camera that aren't x-rated, but it believes are.]")
                sendSMS(sender, "how u doin bae? ;)")
            res.status(200)

app.listen process.env.PORT || 3000
console.log "Listening on #{process.env.PORT || 3000}"