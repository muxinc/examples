# Lambda for Mux Signed Playback

Streaming video from [Mux](https://mux.com/) requires a playback ID.
Mux Playback IDs have two types: `public` and `signed`. 
`public` playback URLs can be watched anywhere, any time. 
`signed` playback URLs require a Mux [signing key](https://docs.mux.com/reference#url-signing-keys)
which is used to generate a token via [JSON Web Tokens](https://jwt.io/).

This example includes an [AWS Lambda](https://aws.amazon.com/lambda/) function that can receive a Mux [playback ID](https://docs.mux.com/reference#playback-ids)
and return a signed url that's ready for use.

## In Use
```bash
# Generate signed playback URL
curl -X POST \
    -H "Content-Type: application/json" \
    -d '{"playbackId": "1234"}' \
    https://example.com/my-example-lambda

# Response
{
    "playbackId": "1234",
    "token": "some-token",
    "signedUrl": "https://stream.mux.com/1234.m3u8?token=some-token"
}
```

Generate a signed playback URL by making a POST request to your lambda. 
Pass `playbackId` and other configuration in the body of the request.

## Deployment
1. Run `yarn build` to bundle all js code and create a zip file that can be uploaded to AWS Lambda.
2. Create a new empty function in AWS Lambda.
3. Change the inline code option to "Upload a zip file" and upload the zip created in the dist folder. 
The handler reference will be `dist/lambda.handler`.
4. Set environment variables `MUX_ACCESS_TOKEN` and `MUX_SECRET`.
5. Add API Gateway as a trigger.
6. Create a test event to confirm that your lambda works.

## Mux features used

- [Playback](https://docs.mux.com/docs/playback)
- [Signed URLs](https://docs.mux.com/docs/security-signed-urls)

## Tools

- [AWS Lambda](https://aws.amazon.com/lambda/)
- [@mux/mux-node](https://github.com/muxinc/mux-node-sdk)
