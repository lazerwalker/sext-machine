;(function() {
  window.InputView = React.createClass({displayName: "InputView",
    render: function() {
      return (
      React.createElement("input", {id: "image-upload", type: "file", accept: "image/*", capture: "camera", onChange: "upload"})
      )
    },
    upload: function() {
      alert("Upload!")
    }
  });

  // The following code gratuitously yanked from
  // https://devcenter.heroku.com/articles/s3-upload-node
  function getSignedRequest(file){
    var xhr = new XMLHttpRequest();
    xhr.open("GET", "/sign_s3?fileName="+file.name+"&fileType="+file.type);
    xhr.onreadystatechange = function() {
      if(xhr.readyState === 4) {
        console.log("Getting ready to upload file")
        if(xhr.status === 200) {
          console.log("Status was 200")
          var response = JSON.parse(xhr.responseText);
          uploadFile(file, response.signedRequest, response.url);
        } else {
          alert("Could not get signed URL.");
        }
      } 
    };
    xhr.send();
  }

  function uploadFile(file, signedRequest, url){
    console.log("Uploading file")
    console.log(file, signedRequest, url)
    
    var xhr = new XMLHttpRequest();
    xhr.open("PUT", signedRequest);
    xhr.setRequestHeader('x-amz-acl', 'public-read');
    xhr.onload = function() {
      if (xhr.status === 200) {
        console.log("Uploaded at " + url);
        var xhr2 = new XMLHttpRequest();
        xhr2.open("GET", "/web?url=" + encodeURIComponent(url));
        xhr2.onreadystatechange = function() {
          if (xhr2.readyState === 4) {
            alert(xhr2.responseText);
          }
        }
        xhr2.send();
      }
    };

    xhr.onerror = function() {
      alert("Could not upload file.");
    };
    
    xhr.send(file);
  }
})();
