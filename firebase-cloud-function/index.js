exports.getMuxAssets = functions.https.onRequest((request, response) => {

  var numAssets = request.query.numAssets;

  // if not given a desired number of assets, assume 1
  if (numAssets === null || numAssets === undefined) {
    console.log("No assets given: assuming 1");
    numAssets = 1;
  } else {
    console.log("Retrieving " + numAssets + " assets");
  }

  const url = 'https://api.mux.com/video/v1/assets?limit=' + numAssets;
  const access_token = functions.config().muxinfo.token;
  const secret_key = functions.config().muxinfo.secretkey;
  const auth_header = access_token + ":" + secret_key;
  const encoded_auth_header = 'Basic ' + Buffer.from(auth_header).toString('base64');

  
  const options = {
    url: url,
    headers: {
      'Authorization': encoded_auth_header
    }
  };

  function callback(error, response2, body) {

    if (error !== null && error !== undefined) {
      console.log("Error: " + error);
      response.status(400).send("Couldn't send HTTP request");
      return 1;
    } 
    if (body === null || body === undefined) {
      console.log("No body");
      response.status(400).send("Did not receive a response body");
    } else {
      console.log("Body: " + body);
      response.status(200).send(body);
    }

    
    return 0;
  }

  requestLib(options, callback);
});