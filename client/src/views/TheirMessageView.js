;(function() {
  window.TheirMessageView = React.createClass({
    render: function() {
      return (
        <div className='message theirs'>
          {this.props.message}
        </div>
      )
    }
  });
})();
