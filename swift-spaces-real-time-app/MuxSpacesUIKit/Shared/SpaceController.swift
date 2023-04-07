//
//  Created for MuxSpacesUIKit.
//  
//  Copyright © 2022 Mux, Inc.
//  Licensed under the MIT License.
//

import Combine

import Foundation

import MuxSpaces

protocol SpaceController: AnyObject {
    var space: Space { get }

    var audioCaptureOptions: AudioCaptureOptions? { get set }
    var cameraCaptureOptions: CameraCaptureOptions? { get set }

    var publishedAudioTrack: AudioTrack? { get set }
    var publishedVideoTrack: VideoTrack? { get set }

    func setupEventHandlers() -> Set<AnyCancellable>

    func upsertParticipant(
        _ participantID: Participant.ID
    )

    func removeParticipant(
        _ participantID: Participant.ID
    )

    func resetSnapshot()
}

extension SpaceController {
    // MARK: - Join space handling

    func joinSpace() -> Set<AnyCancellable> {
        let cancellables = setupEventHandlers()

        space.join(
            options: SpaceOptions(
                displayName: "MuxSpacesUIKitExample"
            )
        )

        return cancellables
    }

    func handleJoinSuccess() {
        #if !targetEnvironment(simulator)
        publishAudioIfNeeded()

        publishVideoIfNeeded()
        #endif
    }

    // MARK: - Leave space handling

    func leaveSpace() {

        self.publishedAudioTrack = nil
        self.publishedVideoTrack = nil

        /// Calling `leave` will unpublish your local tracks
        /// and tear down any open space connections
        /// The SDK will also take care of shutting down the camera
        /// down the camera and mic
        space.leave()
    }

    // MARK: - Publish and Unpublish Tracks

    func publishAudioIfNeeded() {

        guard let audioCaptureOptions else {
            print("Skipping publishing an audio track")
            return
        }

        let audioTrack = space.makeMicrophoneCaptureAudioTrack(
            options: audioCaptureOptions
        )

        space.publishTrack(
            audioTrack
        ) { [weak self] (error: AudioTrack.PublishError?) in

            guard let self = self else { return }

            guard error == nil else {
                print("Error publishing audio track")
                return
            }

            self.publishedAudioTrack = audioTrack
        }
    }

    func unpublishAudio() {
        guard let publishedAudioTrack else {
            return
        }

        space.unpublishTrack(
            publishedAudioTrack
        )
    }

    func publishVideoIfNeeded() {

        guard let cameraCaptureOptions else {
            print("Skipping publishing a video track")
            return
        }

        let videoTrack = space.makeCameraCaptureVideoTrack(
            options: cameraCaptureOptions
        )

        space.publishTrack(
            videoTrack
        ) { [weak self] (error: VideoTrack.PublishError?) in

            guard let self = self else {
                return
            }

            guard error == nil else {
                print("Error publishing video track")
                return
            }

            self.publishedVideoTrack = videoTrack
        }
    }

    func unpublishVideo() {
        guard let publishedVideoTrack else {
            return
        }

        space.unpublishTrack(
            publishedVideoTrack
        )
    }
}
