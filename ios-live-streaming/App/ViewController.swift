//
//  ViewController.swift
//  SampleApp
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
import RPCircularProgress
import Hue
//import MuxLive

public class ViewController: UIViewController {

    // MARK: - properties
    
    private var _broadcastViewController: MuxBroadcastViewController?
    
    private var _stopButton: UIButton?
    private var _streamStatusProgress: RPCircularProgress?
        
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
        
        // setup a broadcast view controller
        self._broadcastViewController = MuxBroadcastViewController()
        if let viewController = self._broadcastViewController {
            viewController.muxBroadcasterDelegate = self
            
            self.addChild(viewController)
            self.view.addSubview(viewController.view)
            viewController.didMove(toParent: self)
        }
        
        var safeAreaTop: CGFloat = UIApplication.shared.statusBarFrame.size.height
        if let window = UIApplication.shared.keyWindow {
            if window.safeAreaInsets.top > 0 {
                safeAreaTop = window.safeAreaInsets.top
            }
        }
        let margin: CGFloat = 15.0
        
        self._streamStatusProgress = RPCircularProgress()
        if let streamStatusProgress = self._streamStatusProgress {
            streamStatusProgress.frame = CGRect(x: 0, y: 0, width: 25, height: 25)
            streamStatusProgress.roundedCorners = true
            streamStatusProgress.thicknessRatio = 0.4
            streamStatusProgress.trackTintColor = UIColor(hex: "#221e1f")
            streamStatusProgress.progressTintColor = UIColor(hex: "#fb3064")
            streamStatusProgress.isUserInteractionEnabled = false
            streamStatusProgress.center = CGPoint(x: self.view.bounds.width - (streamStatusProgress.frame.height * 0.5) - margin,
                                                  y: (streamStatusProgress.frame.width * 0.5) + margin + safeAreaTop)
            self.view.addSubview(streamStatusProgress)
        }
        
        self._stopButton = UIButton(type: .custom)
        if let stopButton = self._stopButton {
            stopButton.setImage(UIImage(named: "close_button"), for: .normal)
            stopButton.sizeToFit()
            stopButton.addTarget(self, action: #selector(handleStopButton(_:)), for: .touchUpInside)
            stopButton.center = CGPoint(x: (stopButton.frame.height * 0.5) + margin,
                                        y: (stopButton.frame.width * 0.5) + margin + safeAreaTop)
            self.view.addSubview(stopButton)
        }
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self._streamStatusProgress?.enableIndeterminate(false, completion: nil)
    }
    
}

// MARK: -  status bar

extension ViewController {
    
    public override var preferredStatusBarStyle: UIStatusBarStyle {
        get {
            return .lightContent
        }
    }
    
}

// MARK: - internal

extension ViewController {
    
    public func presentConnectModal(animated: Bool = true) {
        let connectViewController = ConnectViewController()
        connectViewController.connectDelegate = self
        connectViewController.modalPresentationStyle = .currentContext
        connectViewController.modalTransitionStyle = .coverVertical
        UIApplication.presentViewControllerFromRoot(viewController: connectViewController, animated: animated)
    }
    
}

// MARK: - UIButton

extension ViewController {
    
    @objc public func handleStopButton(_ button: UIButton) {
        self._broadcastViewController?.stop()
        self.presentConnectModal()
    }
    
}

// MARK: - MuxBroadcasterDelegate

extension ViewController: MuxBroadcasterDelegate {
    
    public func muxBroadcaster(_ muxBroadcaster: MuxBroadcastViewController, didChangeState state: MuxLiveState) {
        print("🎬 MuxLive didChangeState, \(state.description)")
        
        switch state {
        case .ready:
            fallthrough
        case .stopped:
            // solid off-black ring
            self._streamStatusProgress?.progressTintColor = UIColor(hex: "#fb3064")
            self._streamStatusProgress?.updateProgress(0, animated: true, initialDelay: 0, completion: nil)
            self._streamStatusProgress?.enableIndeterminate(false, completion: nil)
            break
        case .pending:
            fallthrough
        case .retrying:
            // spinning red ring
            self._streamStatusProgress?.progressTintColor = UIColor(hex: "#fb3064")
            self._streamStatusProgress?.updateProgress(0.3, animated: true, initialDelay: 0, completion: nil)
            self._streamStatusProgress?.enableIndeterminate(true, completion: nil)
            break
        case .started:
            // solid red ring
            self._streamStatusProgress?.progressTintColor = UIColor(hex: "#fb3064")
            self._streamStatusProgress?.updateProgress(1.0, animated: true, initialDelay: 0, completion: nil)
            self._streamStatusProgress?.enableIndeterminate(false, completion: nil)
            break
        case .failed:
            // solid yellow ring
            self._streamStatusProgress?.progressTintColor = UIColor(hex: "#f7df48")
            self._streamStatusProgress?.updateProgress(1.0, animated: true, initialDelay: 0, completion: nil)
            self._streamStatusProgress?.enableIndeterminate(false, completion: nil)
            break
        }
    }

}

// MARK: - ConnectDelegate

extension ViewController: ConnectDelegate {
    
    public func connectViewController(_ viewController: ConnectViewController, didConnectWithStreamKey streamKey: String) {
        // start a broadcast stream
        self._broadcastViewController?.start(withStreamKey: streamKey, interfaceOrientation: UIApplication.shared.statusBarOrientation)
    }
    
}
