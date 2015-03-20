Sext Machine
------------

Sext Machine is a simple SMS game. The Sext Machine is a bot that likes sexting and receiving dirty pictures, but it's not great at knowing what's dirty and what's not. You send it photos over MMS, which it runs through a nudity detection algorithm. Your goal is to trick it by sending it photos that aren't x-rated, but it thinks are.

More information is available at http://lazerwalker.com/sextmachine.html.


Setup
=====
This was designed to be deployable on [Heroku](https://heroku.com).

You'll need to create accounts on [Parse](https://parse.com), [SightEngine](https://sightengine.com) and [Twilio](https://twilio.com), including purchasing a phone number capable of SMS and MMS on Twilio.

If you're using Heroku, you'll need to put the appropriate keys in a .env file (see the top of `app.coffee` for appropriate key names). At this point, you should be able to create a free app using the Cedar stack and deploy as normal.

If you're not using Heroku, any deployment strategy that results in the node process environment having the correct API keys with the correct ENV variable keys should work fine.


A Caveat
========
This was built very quickly, and with more care for the art of the end result than the craftsmanship or maintainability of the code. In other words: don't necessarily look at this code as an example of best practices to emulate.


License
=======
Sext Machine is available under the MIT License. See the LICENSE file in this repository for more information.


Contact
=======
Mike Lazer-Walker

- https://github.com/lazerwalker
- [@lazerwalker](http://twitter.com/lazerwalker)
- http://lazerwalker.com




