//
//  MuxBroadcastViewController.swift
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

import UIKit
import Foundation
import AVFoundation
import NextLevel

/// MuxBroadcasterDelegate, callback delegation for the broadcaster
public protocol MuxBroadcasterDelegate: AnyObject {
    func muxBroadcaster(_ muxBroadcaster: MuxBroadcastViewController, didChangeState state: MuxLiveState)
}

/// MuxBroadcastViewController, provides a simple user interface and permissions handling for MuxLive streaming
public class MuxBroadcastViewController: UIViewController {
    
    // MARK: - properties
    
    public weak var muxBroadcasterDelegate: MuxBroadcasterDelegate?
    
    public var liveState: MuxLiveState {
        get {
            return self._muxLive.liveState
        }
    }
    
    // MARK: - ivars
    
    internal var _previewView: UIView?
    internal var _muxLive: MuxLive = MuxLive()
    
    // MARK: - object lifecycle
    
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("not supported")
    }
    
    // MARK: - view lifecycle
    
    public override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = UIColor.black
        self.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        // setup MuxLive and preview
        self._previewView = UIView(frame: self.view.bounds)
        if let previewView = self._previewView {
            self._muxLive.muxLiveDelegate = self
            self._muxLive.previewView = previewView
            self.view.addSubview(previewView)
        }
        
        // check permissions
        self.checkAndRequestCameraPermission()
        self.checkAndRequestMicrophonePermission()
    }

    private func getInterfaceOrientationMask() -> UIInterfaceOrientationMask {
        switch self.interfaceOrientation {
        case .unknown:
            return .portrait
        case .portraitUpsideDown:
            return .portraitUpsideDown
        case .landscapeLeft:
            return .landscapeLeft
        case .landscapeRight:
            return .landscapeRight
        case .portrait:
            return .portrait
        }
    }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self._muxLive.isRunning = true
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self._muxLive.isRunning = false
        self._muxLive.stop()
    }
    
}

// MARK: -  status bar

extension MuxBroadcastViewController {
    
    public override var preferredStatusBarStyle: UIStatusBarStyle {
        get {
            return .lightContent
        }
    }
    
}

// MARK: - MuxLiveDelegate

extension MuxBroadcastViewController: MuxLiveDelegate {
    
    public func muxLive(_ muxLive: MuxLive, didChangeState state: MuxLiveState) {
        self.muxBroadcasterDelegate?.muxBroadcaster(self, didChangeState: state)
    }
    
    public func muxLive(_ muxLive: MuxLive, didFailWithError error: Error) {
#if DEBUG
        print("MuxLive encountered an error, \(error)")
#endif
    }

}

// MARK: - actions

extension MuxBroadcastViewController {
    
    /// Start a MuxLive stream
    ///
    /// - Parameter streamKey: stream_key from api.mux.com
    public func start(withStreamKey streamKey: String, interfaceOrientation: UIInterfaceOrientation) {
        self._muxLive.start(withStreamKey: streamKey, interfaceOrientation)
    }
    
    /// Stop a MuxLive stream
    public func stop() {
        self._muxLive.stop()
    }
    
}

// MARK: - permissions

extension MuxBroadcastViewController {
    
    /// Launch app settings
    ///
    /// - Parameters:
    ///   - title: Message title string
    ///   - message: Alert message
    open func launchAppSettings(withTitle title: String = NSLocalizedString("⚙️ settings", comment: "⚙️ settings"),
                                  message: String = NSLocalizedString("would you like to open settings?", comment: "would you like to open settings?")) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        
        let okAction = UIAlertAction(title: NSLocalizedString("open", comment: "open"), style: UIAlertAction.Style.default) {
            (action: UIAlertAction) in
            print("UIAlertAction open completion handler");
        }
        let cancelAction = UIAlertAction(title: NSLocalizedString("cancel", comment: "cancel"), style: UIAlertAction.Style.cancel, handler: nil)
        alert.addAction(okAction)
        alert.addAction(cancelAction)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    /// Check and request camera permission
    open func checkAndRequestCameraPermission() {
        let status = NextLevel.authorizationStatus(forMediaType: AVMediaType.video)
        if status == .notAuthorized {
            // looks like they previously denied access, prompt to open settings
            self.launchAppSettings(withTitle: NSLocalizedString("📸 camera access denied", comment: "📸 camera access denied"),
                                   message: NSLocalizedString("would you like to open settings?", comment: "would you like to open settings?"))
        } else {
            NextLevel.requestAuthorization(forMediaType: AVMediaType.video, completionHandler: { (AVMediaType, NextLevelAuthorizationStatus) in
              print("NextLevel.requestAuthorization video completion handler")
            })
        }
    }
    
    /// Check and request mic permission
    open func checkAndRequestMicrophonePermission() {
        let status = NextLevel.authorizationStatus(forMediaType: AVMediaType.audio)
        if status == .notAuthorized {
            // looks like they previously denied access, prompt to open settings
            self.launchAppSettings(withTitle: NSLocalizedString("🎙 mic access denied", comment: "🎙 mic access denied"),
                                   message: NSLocalizedString("would you like to open settings?", comment: "would you like to open settings?"))
        } else {
            NextLevel.requestAuthorization(forMediaType: AVMediaType.audio, completionHandler: { (AVMediaType, NextLevelAuthorizationStatus) in
              print("NextLevel.requestAuthorization audio completion handler")
            })
        }
    }
    
}
