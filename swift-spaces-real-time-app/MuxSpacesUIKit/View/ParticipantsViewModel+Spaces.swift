//
//  ParticipantsViewModel+Spaces.swift
//

import Foundation
import MuxSpaces

extension ParticipantsViewModel {
    // MARK: - Join space handling

    func join() {
        space.join()
    }

    func handleJoinSuccess() {
        publishAudioIfNeeded()

        publishVideoIfNeeded()
    }

    // MARK: - Leave space handling

    func leaveSpace() {

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
        
        guard let videoCaptureOptions else {
            print("Skipping publishing a video track")
            return
        }

        let videoTrack = space.makeCameraCaptureVideoTrack(
            options: videoCaptureOptions
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
