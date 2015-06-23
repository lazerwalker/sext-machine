;(function() {
  window.TheirMessageView = React.createClass({displayName: "TheirMessageView",
    render: function() {
      return (
        React.createElement("div", {className: "message theirs"}, 
          this.props.message
        )
      )
    }
  });
})();
