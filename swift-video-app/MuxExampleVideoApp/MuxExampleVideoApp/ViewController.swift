//
//  ViewController.swift
//  MuxExampleVideoApp
//
//  Created by Dylan Jhaveri on 4/7/21.
//

import UIKit
import AVKit

class ViewController: AVPlayerViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let url = URL(string: "https://bitdash-a.akamaihd.net/content/sintel/hls/playlist.m3u8")
        player = AVPlayer(url: url!)
        player!.play()
        // Do any additional setup after loading the view.
    }


}

