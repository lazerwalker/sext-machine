Twilio = require 'twilio'
Express = require 'express'
SightengineClient = require 'nudity-filter'
Parse = require('parse').Parse
AWS = require('aws-sdk')
Q = require('q')
  
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
app.use('/', Express.static(__dirname + '/client'));


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
    console.log("sending '#{msg}' to '#{to}'")
    TwilioClient.sms.messages.create({to, from:TwilioNum, body:msg})

handleImage = (imageURL, hasOthers=false, conversation) ->
    sender = conversation.get('phone')


    console.log "Received image at #{imageURL}"
    return Q.ninvoke(Sightengine, "checkNudityForURL", imageURL)
        .catch (err) ->
            console.log(error)
            return "can u send again? error w my prgrmming."
        .then (result) ->
            msg = ""
            if result.result
                msg = "that pic makes me like #{result.confidence}% turned on rn"
                if result.confidence >= 85
                    msg += ' :D :D :D'
                else if result.confidence >= 70
                    msg += ' ;)'
                else if result.confidence >= 60
                    msg += ' :)'
                else if result.confidence <= 15
                    msg += " :/"
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

            if hasOthers
                console.log "Uploaded multiple photos"
                Parse.Analytics.track("uploaded multiple photos")
                msg = [msg, "(i can only be turned on by 1 pic at a tmie. send the others again ;P)"]

            return msg


app.get '/sms', (req, res) ->
    fail = -> res.status(500).send("An error has occured")

    sender = req.query.From
    if Array.isArray(sender) then sender = sender[0]

    unless sender?
        Parse.Analytics.track("invalid request", "no sender")
        fail()
        return

    processMessage = (conversation) ->
        image = req.query["MediaUrl0"]
        if image?
            if Array.isArray(image) then image = image[0]
            hasOthers = req.query["MediaUrl1"]?
            handleImage(image, hasOthers, conversation).then (result) ->
                if !Array.isArray(result) then result = [result]
                sendSMS(conversation.get('phone'), msg) for msg in result
        else
            Parse.Analytics.track("no photo")
            sendSMS(sender, "u didnt include a photo :(")
        res.status(200)

    findUser sender,
        found: (conversation) -> processMessage(conversation)
        notFound: () ->
            createNewUser sender, (conversation) ->
                promise = sendSMS(sender, "how u doin bae? ;)")
                promise = promise.then ->
                    sendSMS(sender, "[OPERATIONS MANUAL: Using nudity-detection algorithms, Sext Machine is programmed to feel arousal relative to the likelihood a photo has inappropriate content.")
                promise = promise.then ->
                    sendSMS(sender, "Trick the unit into being aroused by taking and sending pictures with your phone camera that aren't x-rated, but it believes are.]")

            res.status(200)

app.get '/web', (req, res) ->
    processMessage = (conversation) ->
        image = req.query.url
        if image?
            handleImage(image, false, conversation).then (result) ->
                res.json(result)
        else
            Parse.Analytics.track("no photo")
            res.send("u didnt include a photo :(")

    findUser "web",
        found: processMessage
        notFound: (conversation) ->
            createNewUser "web", (conversation) ->
                processMessage(conversation)

app.get '/sign_s3', (req, res) ->
    AWS.config.update 
        accessKeyId: process.env.AWS_ACCESS_KEY
        secretAccessKey: process.env.AWS_SECRET_KEY


    s3 = new AWS.S3()

    file = req.query.fileName.split('.')
    extension = file.pop()
    file = "#{file.join('.')}-#{Date.now()}.#{extension}"

    params = {
        Bucket: process.env.S3_BUCKET
        Key: file
        Expires: 60
        ContentType: req.query.fileType
        ACL: 'public-read'
    }

    s3.getSignedUrl 'putObject', params, (err, data) ->
        result = {
            signedRequest: data,
            url: "https://s3.amazonaws.com/#{params.Bucket}/#{params.Key}"
        }
        console.log("Producing S3 signed request '#{result.signedRequest}' for URL '#{result.url}'")
        res.write(JSON.stringify(result))
        res.end();

app.listen process.env.PORT || 3000
console.log "Listening on #{process.env.PORT || 3000}"