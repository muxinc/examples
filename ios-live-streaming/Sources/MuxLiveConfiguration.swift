//
//  MuxLiveConfiguration.swift
//  MuxLive
//
//  Copyright (c) 2018 Mux, Inc.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//

import Foundation
import AVFoundation
import CoreGraphics

/// MuxLive configuration
public class MuxLiveConfiguration {
}

/// MuxLive audio configuration
public class MuxLiveAudioConfiguration: MuxLiveConfiguration {
    
    /// Audio bit rate (kbps), AV dictionary key AVEncoderBitRateKey
    public var bitRate: Int = 96000
    
    /// Sample rate in hertz, AV dictionary key AVSampleRateKey
    public var sampleRate: Float64 = 44100
    
    /// Number of channels, AV dictionary key AVNumberOfChannelsKey
    public var channelsCount: Int?

}

/// MuxLive video configuration
public class MuxLiveVideoConfiguration: MuxLiveConfiguration {
    
    /// Video frame rate
    public var frameRate: CMTimeScale = 30
    
    /// Max video frame rate
    public var maxFrameRate: CMTimeScale = 30

    /// Min video frame rate
    public var minFrameRate: CMTimeScale = 15
    
    /// Video bit rate (kbps)
    public var bitRate: Int = 800000

    /// Max video bit rate (kbps)
    public var maxBitRate: Int = 960000
    
    /// Min video bit rate (kbps)
    public var minBitRate: Int = 600000
    
    /// Dimensions for video output, AV dictionary keys AVVideoWidthKey, AVVideoHeightKey
    public var dimensions: CGSize?
    
    /// Maximum interval between key frames, 1 meaning key frames only, AV dictionary key AVVideoMaxKeyFrameIntervalKey
    public var maxKeyFrameInterval: Int?
    
}
