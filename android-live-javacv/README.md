# Live streaming on Android using JavaCV

This is just a copy of the [flv example from the JavaCV iOS repo](https://github.com/bytedeco/javacv/blob/master/samples/RecordActivity.java) with a working build setup and some minor adjustments to push an RTMP stream to Mux. The only file that _really_ matters here is just [MainActivity](app/src/main/java/com/example/mmcc/javacvexample/MainActivity.java), basically everything else is just Android Studio stuff to help you run it if you'd like.

The original example takes the devices camera and saves it to an FLV file. Instead, of writing to that FLV file, we push to our stream endpoint at Mux. This is the same process as using [FFmpeg](https://trac.ffmpeg.org/wiki/StreamingGuide) directly to publish an RTMP stream from the command line.

## Usage

If you just want to get up and streaming as quickly as possible, all you need to do is replace the `ffmpeg_link` variable with your own Mux RTMP stream.

## Mux features used

- [Live](https://docs.mux.com/docs/live-streaming)

## Tools

- [JavaCV](https://github.com/bytedeco/javacv)
- [Android Studio](https://developer.android.com/studio)
