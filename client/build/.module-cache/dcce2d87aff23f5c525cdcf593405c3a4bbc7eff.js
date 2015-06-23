;(function() {
  window.InputView = React.createClass({displayName: "InputView",
    render: function() {
      return (
        React.createElement("input", {id: "image-upload", type: "file", accept: "image/*", capture: "camera"})
      )
    }
  });
})();
