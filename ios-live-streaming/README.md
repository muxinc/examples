![Mux iOS Demo Banner](screenshots/banner.png)

# Mux iOS Broadcast Demo

This application is an example of using the free and open source [HaishinKit RTMP library](https://github.com/shogo4405/HaishinKit.swift) to create an iOS app which can broadcast reliably to [Mux](https://mux.com/).

This app replaced the previous iOS example which uses LFLiveKit, but lives in the same repository.

## Functionality

* RTMP broadcasting
* Mid-stream camera switching
* Reconnects on network dropout or network change (EG: Wifi => 4G)
* Primitive RTMP Adaptive Bitrate (Reduces bitrate by 30% every 5 seconds until stable)
* FPS and Bitrate monitoring
* 4 basic profiles broadcasting profiles from 360p @ 1mbps to 1080p @ 5mbps
* Rotation prior to broadcast start

## Demo

![Screen Recording](screenshots/animated.gif)

## Limitations

* Video rotation cannot be changed once broadcasting has started
* 1080p video at 30fps video triggers frame dropping in Haishinkit, which will reduce the frame rate slowly to around 20fps, regardless of device capabilities
* If rotation is triggered during a reconnect window, the reconnect will fail - we can't detect this from the client side

# Quick Start

## Installing and running the project

After cloning this project and installing CocoaPods, run the following command from the project directory to get setup:

```
pod install
```

Then just open the .workspace file and click play to build and run!

```
open *workspace
```

Please note that broadcasting from an iOS simulator is not possible - you'll need a real device to test this application.

## Dependencies

The project requires iOS 13 or higher, and should work on most iPhone and iPad devices. Dependencies deliberately minimal, and are managed using Cocoapods.

# Support

Mux will provides basic support for the features shown in this example. Please raise a GitHub issue if you run into problems, but remember that we are limited to functionality that Haishinkit provides.

# Documentation

## Overview

This project uses [HaishinKit RTMP library](https://github.com/shogo4405/HaishinKit.swift) to reliably broadcast a live stream from an iOS device to an RTMP endooint, in this case, [Mux](https://mux.com/).

## Code Overview

### AppDelegate.swift

When you're implementing your own application using HaishinKit, please be sure to add the boilerplate code from `application` function to your application - this will ensure that your application is able to attatch to the different audio devices that your iPhone or iPad might have.

### ConnectViewController.swift

This View Controller acts as the entrypoint of the application, and allows the user to enter a Stream Key.

### BroadcastViewController.swift

Most of the application is implemented in BroadcastViewController.swift, it's fairly short, around 250 lines right now, and is deliberately not broken into multiple files or classes. Here's an overview of how it works. 

#### viewDidLoad()

When the application is started, the main entrypoint, `viewDidLoad()` is called. First, this then performs basic boilerplate to setup the `RTMPStream` and `RTMPConnection`, and initialise the preview. Mainly this configures the RTMP stream quality (bitrate and resolution). We've included 4 sample profiles with the application which should act as a good baseline for deciding the quality of your input stream.

``` swift
    // Work out the orientation of the device, and set this on the RTMP Stream
    // Note: Changing the orientation is not supported once the stream has been started.
    rtmpStream = RTMPStream(connection: rtmpConnection)
    if let orientation = DeviceUtil.videoOrientation(by: UIApplication.shared.statusBarOrientation) {
        rtmpStream.orientation = orientation
    }
    
    // Configure the encoder profile
    configureStream(preset: .hd_1080p_30fps_5mbps, isVertical: true)
    
    // Attatch to the default audio device
    rtmpStream.attachAudio(AVCaptureDevice.default(for: .audio)) { error in
        print(error.description)
    }
    
    // Attatch to the default camera
    rtmpStream.attachCamera(DeviceUtil.device(withPosition: defaultCamera)) { error in
        print(error.description)
    }

    // Attatch the preview view
    previewView?.attachStream(rtmpStream)
```

Finally in `viewDidLoad`, we register some callbacks with HaishinKit, which is how we'll manage our connections to the RTMP server.

``` swift
    // Add event listeners for RTMP status changes and IO Errors
    rtmpConnection.addEventListener(.rtmpStatus, selector: #selector(rtmpStatusHandler), observer: self)
    rtmpConnection.addEventListener(.ioError, selector: #selector(rtmpErrorHandler), observer: self)
```

#### goLiveButton()

When the "Go Live" button is tapped, we check if we have an RTMP connection, and if we don't, we attempt the RTMP connection by calling `connect()` on the `RTMPConnection`.

``` swift
    if rtmpConnection.connected {
        // If we're already connected to the RTMP server, wr can just call publish() to start the stream
        publishStream()
    } else {
        // Otherwise, we need to setup the RTMP connection and wait for a callback before we can safely
        // call publish() to start the stream
        connectRTMP()
    }
```

The rest happens in the callbacks we registered earlier. When the `RTMPConnection` transitions into a `RTMPConnection.Code.connectSuccess` state, we call `publish()` to begin the live stream.

We also listen for callbacks when the `RTMPConnection` closes or fails. This allows us to retry the RTMP connection automatically in case of network connectivity issues. 

Note that `publish()` should never be called synchronously if you aren't absolutely sure that the `RTMPConnection` is connected, only from a callback when the `RTMPConnection` transitions into the `RTMPConnection.Code.connectSuccess` state.
