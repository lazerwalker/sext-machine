;(function() {
  var Type = {
    BOT: 0,
    YOU: 1
  }
  window.ChatView = React.createClass({
    getInitialState: function() {
      var messages;
      if (localStorage.messages) {
        messages = JSON.parse(localStorage.messages);
      } else {
        messages = [
          {type: Type.BOT, msg: "how u doin bae? ;)"},
          {type: Type.BOT, msg: "[OPERATIONS MANUAL: Using nudity-detection algorithms, Sext Machine is programmed to feel arousal relative to the likelihood a photo has inappropriate content."},
          {type: Type.BOT, msg:"Trick the unit into being aroused by taking and sending pictures with your phone camera that aren't x-rated, but it believes are.]"}
        ]
      }
      return { messages: messages }
    },
    componentDidUpdate: function() {
      document.body.scrollTop = document.body.scrollHeight;
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
          <HeaderView/>
          <div className='messages'>
            {messages}
          </div>
          <InputView 
            onUpload={this.uploadedPhoto}
            onJudgement={this.judgedPhoto}
          />
        </div>
      )
    },
    uploadedPhoto: function(file) {
      var messages = this.state.messages;
      console.log("In uploadedPhoto")
      var reader = new FileReader();

      var view = this;
      reader.onload = function (e) {
        console.log("Loaded", e)
        messages.push({type: Type.YOU, url: e.target.result});
        view.setState({messages: messages})
        localStorage.messages = JSON.stringify(messages);
      };
      reader.readAsDataURL(file);

    },
    judgedPhoto: function(url, judgementString) {
      var messages = this.state.messages;
      var newest = {type: Type.BOT, msg:judgementString};
      messages.push(newest)
      this.setState({messages: messages})

      messages.pop()
      messages.push({type: Type.YOU, url:url})
      messages.push(newest)

      localStorage.messages = JSON.stringify(messages);    
    }
  });
})();
