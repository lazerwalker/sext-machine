;(function() {
  var ChatView = React.createClass({displayName: "ChatView",
    render: function() {
      return (
        React.createElement("div", {className: "chatView"}, 
        "I AM A CHATVIEW"
        )
      )
    }
  });

  window.ChatView = ChatView;
})();
