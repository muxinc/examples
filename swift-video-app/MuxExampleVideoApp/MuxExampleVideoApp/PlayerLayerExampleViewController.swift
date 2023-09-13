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
            environmentKey: "ENV_KEY"
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
            view.leadingAnchor.constraint(
                equalTo: playerView.leadingAnchor
            ),
            view.trailingAnchor.constraint(
                equalTo: playerView.trailingAnchor
            ),
            view.topAnchor.constraint(
                equalTo: playerView.topAnchor
            ),
            view.bottomAnchor.constraint(
                equalTo: playerView.bottomAnchor
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
        playerView.player?.play()
    }
}


