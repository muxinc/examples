//
//  PlayerLayerExampleViewController.swift
//  MuxExampleVideoApp
//

import UIKit
import MUXSDKStats

/// UIView container for AVPlayerLayer
class PlayerView: UIView {
    override class var layerClass: AnyClass {
        AVPlayerLayer.self
    }

    var playerLayer: AVPlayerLayer? {
        layer as? AVPlayerLayer
    }

    var player: AVPlayer? {
        get {
            (layer as? AVPlayerLayer)?.player
        }
        set {
            (layer as? AVPlayerLayer)?.player = newValue
        }
    }
}

/// Bare bones AVPlayerLayer example without controls or
/// other affordances
class PlayerLayerExampleViewController: UIViewController {
    lazy var playbackURL = URL(
        string: "https://stream.mux.com/qxb01i6T202018GFS02vp9RIe01icTcDCjVzQpmaB00CUisJ4.m3u8"
    )!

    lazy var playerView = PlayerView()

    override func viewDidLoad() {
        super.viewDidLoad()

        let playerName = "iOS AVPlayer"
        let playerData = MUXSDKCustomerPlayerData(
            environmentKey: ""
        )
        let videoData = MUXSDKCustomerVideoData()
        let customerData = MUXSDKCustomerData(
            customerPlayerData: playerData,
            videoData: videoData,
            viewData: nil
        )!

        playerView.backgroundColor = .black

        playerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(playerView)
        view.addConstraints([
            view.centerXAnchor.constraint(
                equalTo: playerView.centerXAnchor
            ),
            view.centerYAnchor.constraint(
                equalTo: playerView.centerYAnchor
            ),
            view.widthAnchor.constraint(
                equalTo: playerView.widthAnchor
            ),
            view.heightAnchor.constraint(
                equalTo: playerView.heightAnchor
            ),
        ])

        playerView.player = AVPlayer(
            url: playbackURL
        )

        guard let playerLayer = playerView.layer as? AVPlayerLayer else {
            return
        }

        MUXSDKStats.monitorAVPlayerLayer(
            playerLayer,
            withPlayerName: playerName,
            customerData: customerData
        )
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        startObservingPlayerAccessLog()
        playerView.player?.play()
    }

    func startObservingPlayerAccessLog() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(PlayerLayerExampleViewController.handlePlayerAccessLogEntryUpdate),
            name: AVPlayerItem.newAccessLogEntryNotification,
            object: nil
        )
    }

    @objc func handlePlayerAccessLogEntryUpdate(
        _ notification: Notification
    ) {
        guard let playerItem = (notification.object as? AVPlayerItem) else {
            print("\(#function) No player item enclosed with notification")
            return
        }

        print("\(#function) Preferred peak bitrate \(playerItem.preferredPeakBitRate)")

        print("\(#function) Preferred maximum resolution \(playerItem.preferredMaximumResolution)")

        if #available(iOS 15.0, *) {
            print("\(#function) Preferred peak bitrate \(playerItem.preferredPeakBitRateForExpensiveNetworks)")

            print("\(#function) Preferred maximum resolution \(playerItem.preferredMaximumResolutionForExpensiveNetworks)")
        }

        guard let accessLog = playerItem.accessLog() else {
            print("\(#function) No access log enclosed with notification")
            return
        }

        guard let lastEvent = accessLog.events.last else {
            print("\(#function) Access log empty after an update")
            return
        }

        print("\(#function) Current Indicated Bitrate: \(lastEvent.indicatedBitrate)")

        print("\(#function) Current Observed Bitrate: \(lastEvent.observedBitrate)")

        print("\(#function) Current Switch Bitrate: \(lastEvent.switchBitrate)")

        print("\(#function) Observed Bitrate Standard Deviation: \(lastEvent.observedBitrateStandardDeviation)")

        print("\(#function) URI: \(String(describing: lastEvent.uri))")
    }
}


