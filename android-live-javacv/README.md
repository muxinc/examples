# Live streaming on Android using JavaCV

This is just a copy of the [flv example from the JavaCV iOS repo](https://github.com/bytedeco/javacv/blob/master/samples/RecordActivity.java) with a working build setup and some minor adjustments to push an RTMP stream to Mux.

The original example takes the devices camera and saves it to an FLV file. Instead, of writing to that FLV file, we push to our stream endpoint at Mux. This is the same process as using [FFmpeg](https://trac.ffmpeg.org/wiki/StreamingGuide) directly to publish an RTMP stream from the command line.

## Usage


## Mux features used

- [Live](https://docs.mux.com/docs/live-streaming)

## Tools

- [JavaCV](https://github.com/bytedeco/javacv)
- [Android Studio](https://developer.android.com/studio)
