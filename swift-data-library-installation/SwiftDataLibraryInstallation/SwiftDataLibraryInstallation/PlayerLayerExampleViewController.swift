//
//  PlayerLayerExampleViewController.swift
//  SwiftDataLibraryInstallation
//

import AVFoundation
import UIKit

import MuxDataContainer

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
    let playerName = "AVPlayerLayerExample"

    lazy var playerView = PlayerView()

    override func viewDidLoad() {
        super.viewDidLoad()

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

        MonitoringContainer.shared.monitor(
            playerLayer: playerLayer,
            playerName: playerName,
            videoID: "VideoBehindTheScenes",
            videoTitle: "Video Behind the Scenes",
            environmentKey: ProcessInfo.processInfo.environmentKey
        )
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        playerView.player?.play()
    }

    override func viewWillDisappear(_ animated: Bool) {
        MonitoringContainer.shared.destroyPlayer(
            playerName
        )
        super.viewWillDisappear(animated)
    }
}



