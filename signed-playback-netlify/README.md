# Netlify create mux signed urls

This app uses [Netlify functions](https://www.netlify.com/docs/functions/) to create one
Netlify endpoint that will 302 redirect to a signed MUX url

# Usage

When this is deployed you can use a netlify function as the endpoint for your player src,
either in a web player or a native player.

Web example

```html
<video src="https://<your-netlify-project>.netlify.com/.netlify/functions/sign_playback_id?playbackId=<playback-id>"></video>
```

iOS AVPlayer example

```swift
let url = URL(string: "https://<your-netlify-project>.netlify.com/.netlify/functions/sign_playback_id?playbackId=<playback-id>")
player = AVPlayer(url: url!)
player!.play()
```

The netlify endpoint will 302 redirect to the signed URL

# Example (dev)

1. Run netlify dev in one terminal

> netlify dev

You should see a local dev server running

2. Run netlify-lambda in another terminal window

> netlify-lambda server ./functions

You should see that netlify-lambda watches the ./functions directory and compiles
changes into your build director (.netifly/.functions)

3. Curl your local dev server

```
curl -I  'http://localhost:56348/.netlify/functions/sign_playback_id?playbackId=<playback-id>'
```

You should see a 302 (redirect) with a `location` header that is the full signed mux url:

`https://stream.mux.com/<playback-id>.m3u8?token=<token>`


# Deploy

1. Build using `netlify-lambda` and deploy with `netlify deploy`

> netlify-lambda build ./functions` && netlify deploy --prod
