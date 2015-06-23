document.addEventListener('DOMContentLoaded', function() {
  console.log("Creating?")
  React.render(
    React.createElement(ChatView, null),
    document.getElementById('main')
  );
});


