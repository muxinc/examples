//
//  SceneDelegate.swift
//  MuxExampleVideoApp
//
//  Created by Dylan Jhaveri on 4/7/21.
//

import UIKit
import AVKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    var videoViewController: ViewController? = nil
    var avPlayerSavedReference: AVPlayer? = nil

    var enteringPictureInPicture: Bool = false

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let _ = (scene as? UIWindowScene) else { return }
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
        //
        // Now that the application is coming into the foreground, we should
        // have a avPlayerSavedReference (from the last time it went into the background)
        // Let's re-attached our avPlayerSavedReference onto our ViewController

        if let videoViewController, let avPlayerSavedReference, !enteringPictureInPicture {
            avPlayerSavedReference.currentItem?.preferredPeakBitRate = 0
            videoViewController.playerViewController.player = avPlayerSavedReference
            self.avPlayerSavedReference = nil
        }
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Detach our avPlayer from the view controller, but save
        // a reference to it so we can re-attach it later
        if let videoViewController, !enteringPictureInPicture {
            avPlayerSavedReference = videoViewController.playerViewController.player
            videoViewController.playerViewController.player = nil
        }
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }


}

