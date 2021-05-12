//
//  ViewController.swift
//  MuxExampleVideoApp
//
//  Created by Dylan Jhaveri on 4/7/21.
//

import UIKit
import AVKit
import MUXSDKStats

class ViewController: AVPlayerViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let url = URL(string: "https://stream.mux.com/qxb01i6T202018GFS02vp9RIe01icTcDCjVzQpmaB00CUisJ4.m3u8")
        player = AVPlayer(url: url!)
        let playName = "iOS AVPlayer"
        let playerData = MUXSDKCustomerPlayerData(environmentKey: "ENV_KEY")
        let videoData = MUXSDKCustomerVideoData();
        MUXSDKStats.monitorAVPlayerViewController(self, withPlayerName: playName, playerData: playerData!, videoData: videoData);
        //
        // Pick One:
        //   - picture-in-picture capabilities or
        //   - play audio when the scene enters background
        //
        // For this app, we are disabling picture in picture so that
        // we can listen for the scene to go into the background and
        // let the audio keep playing. The problem right now is that
        // there is no easy way in the SceneDelegate to know if the background
        // happened because the phone was locked or the background happened
        // because of picture in picture.
        //
        self.allowsPictureInPicturePlayback = false
        player!.play()

        let scene = UIApplication.shared.connectedScenes.first
        if let sceneDelegate : SceneDelegate = (scene?.delegate as? SceneDelegate) {
            sceneDelegate.videoViewController = self;
        }
    }
}

