SUMMARY

A Firebase-hosted script to get asset information through the Mux API


SETUP

1. Set up Firebase Cloud Functions if you haven't already (https://firebase.google.com/docs/functions/get-started)

2. Copy the code into your own index.js file

3. Paste and run the following in Terminal / Command Prompt (inserting your own Mux token and secret key):

	firebase functions:config:set muxInfo.token="YOUR TOKEN" muxInfo.secretkey="YOUR SECRET KEY"

	firebase deploy --only functions


4. The URL for the function will be given to you in response, and can also be found on the Firebase console.




USAGE

The function can be triggered as a regular HTTPS GET request at the above URL with no additional arguments. However,
if you want to specify a number of assets to be returned, you can do so with a numAssets query variable. The 
following will return 5 assets:

	<your function URL>?numAssets=5


-- Courtesy of Paladin Drones