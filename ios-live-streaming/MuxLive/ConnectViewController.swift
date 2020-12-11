//  Copyright Mux Inc. 2020.

import Foundation
import UIKit
import Loaf

class ConnectViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var streamKeyTextBox: MuxTextField!
    @IBOutlet weak var presetSelector: UISegmentedControl!
    @IBOutlet weak var startCameraButton: MuxButton!
    
    // If you're testing in a tight loop, you won't want to paste a stream key each time.
    // Instead, set a static stream key below.
    let defaultStreamKey = ""
    
    var streamKey = ""
    
    // Lazily ordered in the same order that the segmented controler displays them
    var segmentedPresets = [BroadcastViewController.Preset.hd_1080p_30fps_5mbps,
                            BroadcastViewController.Preset.hd_720p_30fps_3mbps,
                            BroadcastViewController.Preset.sd_540p_30fps_2mbps,
                            BroadcastViewController.Preset.sd_360p_30fps_1mbps]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.streamKeyTextBox.delegate = self
    }
    
    // Suppress return button on the text field
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is BroadcastViewController
        {
            let vc = segue.destination as? BroadcastViewController
            vc?.streamKey = streamKey
            vc?.preset = segmentedPresets[presetSelector.selectedSegmentIndex]
        }
    }
    
    @IBAction func startCamera(_ sender: Any) {
            
        streamKey = streamKeyTextBox.text!
        
        // Use the hardwired default stream key if it exists, and there's nothing in the text box
        if streamKey == "" && defaultStreamKey != "" {
            streamKey = defaultStreamKey
        }
        
        if streamKey == "" {
            Loaf("Enter a Stream Key!", state: Loaf.State.warning, location: .top,  sender: self).show(.short)
            return
        }
        
        performSegue(withIdentifier: "startCamera", sender: sender)
    }
}
