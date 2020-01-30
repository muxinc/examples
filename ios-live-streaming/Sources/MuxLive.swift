//
//  MuxLive.swift
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
import Alamofire
import LFLiveKit

// MARK: - types

public let MuxLiveApiProductionHostname = "api.mux.com"
public let MuxLiveRtmpProductionUrl = "rtmp://live.mux.com/app/"

/// Stream state
public enum MuxLiveState: Int, CustomStringConvertible {
    case ready
    case pending
    case started
    case stopped
    case failed
    case retrying
    
    public var description: String {
        get {
            switch self {
            case .ready:
                return "Ready"
            case .pending:
                return "Pending"
            case .started:
                return "Started"
            case .stopped:
                return "Stopped"
            case .failed:
                return "Failed"
            case .retrying:
                return "Retrying"
            }
        }
    }
}

/// Error domain for all MuxLive errors.
public let MuxLiveErrorDomain = "MuxLiveErrorDomain"

/// Error types.
public enum MuxLiveError: Error, CustomStringConvertible {
    case unknown
    case streamingInfoFailure
    case connectionFailure
    case verificationFailure
    case timeout
    
    public var code: Int {
        get {
            switch self {
            case .unknown:
                return 0
            case .streamingInfoFailure:
                return 202
            case .connectionFailure:
                return 203
            case .verificationFailure:
                return 204
            case .timeout:
                return 205
            }
        }
    }
    
    public var description: String {
        get {
            switch self {
            case .unknown:
                return "Unknown"
            case .streamingInfoFailure:
                return "Failure obtaining streaming information"
            case .connectionFailure:
                return "Connection failure"
            case .verificationFailure:
                return "Verification failure"
            case .timeout:
                return "Server timeout"
            }
        }
    }
}

// MARK: - MuxLive

/// MuxLiveDelegate protocol, callback for receiving updates from MuxLive
public protocol MuxLiveDelegate: AnyObject {
    func muxLive(_ muxLive: MuxLive, didChangeState state: MuxLiveState)
    func muxLive(_ muxLive: MuxLive, didFailWithError error: Error)
}

/// MuxLive, a live video streaming SDK for iOS
public class MuxLive: NSObject {

    // MARK: - properties
    
    /// Delegate properties
    public weak var muxLiveDelegate: MuxLiveDelegate?
    
    /// Audio configuration
    public var audioConfiguration: MuxLiveAudioConfiguration = MuxLiveAudioConfiguration()
    
    /// Video configuration
    public var videoConfiguration: MuxLiveVideoConfiguration = MuxLiveVideoConfiguration()

    /// Network reachability status of api.mux.com
    public var networkReachable: Bool {
        get {
            return self._reachabilityStatus != .notReachable
        }
    }
    
    /// Preview of stream, provide a view for rendering
    public var previewView: UIView? {
        didSet {
            if let previewView = self.previewView {
                self._liveSession?.preView = previewView
            }
        }
    }

    /// Pause/resume local video capture
    public var isRunning: Bool = false {
        didSet {
            self._liveSession?.running = self.isRunning
        }
    }
    
    /// Stream state
    public var liveState: MuxLiveState {
        get {
            if let lfLiveState = self._liveSession?.state {
                return MuxLiveState(rawValue: Int(lfLiveState.rawValue)) ?? .ready
            } else {
                return .ready
            }
        }
    }
    
    // MARK: - ivars

    private var _reachabilityManager: NetworkReachabilityManager?
    private var _reachabilityStatus: NetworkReachabilityManager.NetworkReachabilityStatus = .unknown
    
    private var _configuration: URLSessionConfiguration?
    
    private var _clientSession: SessionManager? // mux api (future)
    private var _liveSession: LFLiveSession?    // mux stream
    
    // MARK: - singleton
    
    /// Singleton (if desired)
    public static let shared = MuxLive()
    
    // MARK: - Object lifecycle
    
    /// Initializer
    public override init() {
        self._reachabilityManager = NetworkReachabilityManager(host: MuxLiveApiProductionHostname)
        super.init()
    }
    
}

// MARK: - internal setup

extension MuxLive {
    
    internal func setupLiveSession(_ orientation: UIInterfaceOrientation) {
        let audioConfiguration = LFLiveAudioConfiguration.default()
        if let channelsCount = self.audioConfiguration.channelsCount {
            audioConfiguration?.numberOfChannels = UInt(channelsCount)
        }
        audioConfiguration?.audioBitrate = self.lfLiveKitAudioBitRate(withBitRate: self.audioConfiguration.bitRate)
        audioConfiguration?.audioSampleRate = self.lfLiveKitAudioSampleRate(withSampleRate: self.audioConfiguration.sampleRate)
        
        let videoConfiguration = LFLiveVideoConfiguration.defaultConfiguration(for: .medium3, outputImageOrientation: orientation)
        if let dimensions = self.videoConfiguration.dimensions {
            videoConfiguration?.videoSize = dimensions
        }
        videoConfiguration?.videoFrameRate = UInt(self.videoConfiguration.frameRate)
        videoConfiguration?.videoMaxFrameRate = UInt(self.videoConfiguration.maxFrameRate)
        videoConfiguration?.videoMinFrameRate = UInt(self.videoConfiguration.minFrameRate)
        videoConfiguration?.videoBitRate = UInt(self.videoConfiguration.bitRate)
        videoConfiguration?.videoMaxBitRate = UInt(self.videoConfiguration.maxBitRate)
        videoConfiguration?.videoMinBitRate = UInt(self.videoConfiguration.minBitRate)
        if let maxKeyFrameInterval = self.videoConfiguration.maxKeyFrameInterval {
            videoConfiguration?.videoMaxKeyframeInterval = UInt(maxKeyFrameInterval)
        }

        self._liveSession = LFLiveSession(audioConfiguration: audioConfiguration, videoConfiguration: videoConfiguration)!
        if let liveSession = self._liveSession {
            liveSession.delegate = self
            liveSession.captureDevicePosition = .back
            
            if let previewView = self.previewView {
                liveSession.preView = previewView
            }
        }
    }

}

// MARK: - internal LFLiveKit wrappers

extension MuxLive {
    
    // audio type wrappers
    
    internal func lfLiveKitAudioBitRate(withBitRate bitRate: Int) -> LFLiveAudioBitRate {
        var lfBitRate = LFLiveAudioBitRate._Default
        if bitRate <= 32000 {
            lfBitRate = LFLiveAudioBitRate._32Kbps
        } else if bitRate <= 64000 {
            lfBitRate = LFLiveAudioBitRate._64Kbps
        } else if bitRate <= 96000 {
            lfBitRate = LFLiveAudioBitRate._96Kbps
        } else if bitRate <= 128000 {
            lfBitRate = LFLiveAudioBitRate._128Kbps
        }
        return lfBitRate
    }
    
    internal func lfLiveKitAudioSampleRate(withSampleRate sampleRate: Float64) -> LFLiveAudioSampleRate {
        var lfSampleRate = LFLiveAudioSampleRate._Default
        if sampleRate <= 16000 {
            lfSampleRate = LFLiveAudioSampleRate._16000Hz
        } else if sampleRate <= 44100 {
            lfSampleRate = LFLiveAudioSampleRate._44100Hz
        } else if sampleRate <= 48000 {
            lfSampleRate = LFLiveAudioSampleRate._48000Hz
        }
        return lfSampleRate
    }
    
}

// MARK: - actions

extension MuxLive {
    
    /// Start broadcast
    public func start(withStreamKey streamKey: String, _ orientation: UIInterfaceOrientation) {
        self.setupLiveSession(orientation)

        // Check that the stream key is actually a key and not a full address
        var streamUrlString = MuxLiveRtmpProductionUrl + streamKey
        if streamKey.range(of: "rtmp://") != nil {
            streamUrlString = streamKey
        }
        
        let streamInfo = LFLiveStreamInfo()
        streamInfo.url = streamUrlString
        self._liveSession?.startLive(streamInfo)
    }
    
    /// Stop broadcast
    public func stop() {
        self._liveSession?.stopLive()
        self._liveSession?.delegate = nil
        self._liveSession = nil
    }
    
}

// MARK: - LFLiveSessionDelegate

extension MuxLive: LFLiveSessionDelegate {
    
    public func liveSession(_ session: LFLiveSession?, debugInfo: LFLiveDebug?) {
        // print("🎬 debugInfo: \(debugInfo?.currentBandwidth)")
    }
    
    public func liveSession(_ session: LFLiveSession?, liveStateDidChange state: LFLiveState) {
        let state = MuxLiveState(rawValue: Int(state.rawValue)) ?? .ready
        self.muxLiveDelegate?.muxLive(self, didChangeState: state)
    }
    
    public func liveSession(_ session: LFLiveSession?, errorCode: LFLiveSocketErrorCode) {
        var muxLiveError = MuxLiveError.unknown
        switch errorCode {
        case LFLiveSocketErrorCode.getStreamInfo:
            muxLiveError = MuxLiveError.streamingInfoFailure
            break
        case LFLiveSocketErrorCode.connectSocket:
            muxLiveError = MuxLiveError.streamingInfoFailure
            break
        case LFLiveSocketErrorCode.verification:
            muxLiveError = MuxLiveError.verificationFailure
            break
        case LFLiveSocketErrorCode.reConnectTimeOut:
            muxLiveError = MuxLiveError.timeout
            break
        default:
            break
        }
        self.muxLiveDelegate?.muxLive(self, didFailWithError: muxLiveError)
    }
}
