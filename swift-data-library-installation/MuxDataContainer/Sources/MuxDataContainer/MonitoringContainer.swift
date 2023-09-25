//
//  MonitoringContainer.swift
//
//

import AVFoundation
import AVKit
import Foundation

import MuxCore
import MUXSDKStats

public class MonitoringContainer {

    public static let shared = MonitoringContainer()

    public func monitor(
        playerViewController: AVPlayerViewController,
        playerName: String,
        videoID: String,
        videoTitle: String,
        environmentKey: String?
    ) {

        let playerData = MUXSDKCustomerPlayerData()
        playerData.environmentKey = environmentKey

        let videoData = MUXSDKCustomerVideoData()
        videoData.videoId = videoID
        videoData.videoTitle = videoTitle

        let customerData = MUXSDKCustomerData(
            customerPlayerData: playerData,
            videoData: videoData,
            viewData: nil
        )!

        MUXSDKStats.monitorAVPlayerViewController(
            playerViewController,
            withPlayerName: playerName,
            customerData: customerData
        )
    }

    public func monitor(
        playerLayer: AVPlayerLayer,
        playerName: String,
        videoID: String,
        videoTitle: String,
        environmentKey: String?
    ) {

        let playerData = MUXSDKCustomerPlayerData()
        playerData.environmentKey = environmentKey

        let videoData = MUXSDKCustomerVideoData()
        videoData.videoId = videoID
        videoData.videoTitle = videoTitle

        let customerData = MUXSDKCustomerData(
            customerPlayerData: playerData,
            videoData: videoData,
            viewData: nil
        )!

        MUXSDKStats.monitorAVPlayerLayer(
            playerLayer,
            withPlayerName: playerName,
            customerData: customerData
        )
    }

    public func destroyPlayer(
        _ playerName: String
    ) {
        MUXSDKStats.destroyPlayer(playerName)
    }

}
