# swift-video-app

This is a swift app that uses AVPlayer, AVPlayerViewController and MuxData. The video source is a Mux Video HLS manifest, but that can be swapped out for any AVPlayer compatible source.

The main thing to test here was to get the audio to continue playing when the application enters the background. We wrote about it on [the Mux blog](mux.com/blog/background-audio-handling-with-ios-avplayer).
