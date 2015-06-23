;(function() {
  window.PhotoView = React.createClass({
    render: function() {
      return (
        <div className='message mine image'>
            <img src={this.props.url} />
        </div>
      )
    }
  });
})();
