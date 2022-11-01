//
//  ParticipantsViewModel+Space.swift
//

import Foundation
import MuxSpaces

extension ParticipantsViewModel {

    // MARK: - Convenience constructor

    static func make(
        with token: String,
        audioCaptureOptions: AudioCaptureOptions?,
        videoCaptureOptions: CameraCaptureOptions?
    ) -> ParticipantsViewModel? {

        // Check that the token is not empty
        // before proceeding
        guard !token.isEmpty else {
            return nil
        }

        // Initialize a Space with a pre-generated token
        guard let space = try? Space(
            token: token
        ) else {
            return nil
        }

        // Initialize a view model that will translate
        // Space state changes to changes in the app UI
        let viewModel = ParticipantsViewModel(
            space: space,
            audioCaptureOptions: audioCaptureOptions,
            cameraCaptureOptions: videoCaptureOptions
        )

        return viewModel
    }

    // MARK: - Join space handling

    func joinSpace() {
        space.join()
    }

    func handleJoinSuccess() {
        publishAudioIfNeeded()

        publishVideoIfNeeded()
    }

    // MARK: - Leave space handling

    func leaveSpace() {

        self.publishedAudioTrack = nil
        self.publishedVideoTrack = nil

        /// Delete the contents of the collection view
        self.snapshot.deleteAllItems()

        /// Calling `leave` will unpublish your local tracks
        /// and tear down any open space connections
        /// The SDK will also take care of shutting down the camera
        /// down the camera and mic
        space.leave()

        cancellables.forEach { $0.cancel() }
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
                return
            }

            self.publishedAudioTrack = audioTrack
        }
    }

    func unpublishAudio() {
        guard let publishedAudioTrack = publishedAudioTrack else {
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
        ) { (error: VideoTrack.PublishError?) in
            guard error == nil else {
                return
            }

            self.publishedVideoTrack = videoTrack
        }
    }

}
