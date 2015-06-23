;(function() {
  window.PhotoView = React.createClass({displayName: "PhotoView",
    render: function() {
      return (
        React.createElement("div", {className: "message mine image"}, 
            React.createElement("img", {src: this.props.url})
        )
      )
    }
  });
})();
