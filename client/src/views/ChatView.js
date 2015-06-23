;(function() {
  var Type = {
    BOT: 0,
    YOU: 1
  }
  window.ChatView = React.createClass({
    getInitialState: function() {
      return {
        messages: [
          {type: Type.BOT, msg: "how u doin bae? ;)"},
          {type: Type.BOT, msg: "[OPERATIONS MANUAL: Using nudity-detection algorithms, Sext Machine is programmed to feel arousal relative to the likelihood a photo has inappropriate content."},
          {type: Type.BOT, msg:"Trick the unit into being aroused by taking and sending pictures with your phone camera that aren't x-rated, but it believes are.]"}
        ]
      }
    },
    render: function() {
      var messages = this.state.messages.map(function(msg) {
        if (msg.type === Type.BOT) {
          return <TheirMessageView 
            message={msg.msg}
            key={msg.msg}
          ></TheirMessageView>
        } else if (msg.type === Type.YOU) {
          return <PhotoView url={msg.url} key={msg.url}/>
        }
      });
      return (
        <div>
          {messages}
          <InputView 
            onUpload={this.uploadedPhoto}
          />
        </div>
      )
    },
    uploadedPhoto: function(photo) {
      var messages = this.state.messages;
      messages.push({type: Type.YOU, url: photo});
      this.setState({messages: messages})
    }
  });
})();
