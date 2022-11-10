//
//  ParticipantsViewModel+Space.swift
//

import Combine
import Foundation
import MuxSpaces

extension ParticipantsViewModel {

    // MARK: - Setup Observers on Space State Updates

    func setupEventHandlers() {
        /// Setup observers that will update your views state
        /// based on events that are produced by the space
        ///
        space
            .events
            .joinSuccesses
            .sink { [weak self] _ in
                guard let self = self else {
                    return
                }

                self.handleJoinSuccess()
            }
            .store(in: &cancellables)

        Combine.Publishers.Merge5(
            /// Participant joined events trigger a new
            /// cell to be added for each new participant
            space.events
                .participantJoined
                .map(\.participant.connectionID),
            /// When the SDK subscribes to a new video track,
            /// the participants video becomes available to display
            space.events
                .videoTrackSubscriptions
                .map(\.participant.connectionID),
            /// When the SDK unsubscribes from a video track,
            /// the participants video should be taken down
            /// this update is handled in ParticipantsViewModel
            space.events
                .videoTrackUnsubscriptions
                .map(\.participant.connectionID),
            // We only want to know when our own tracks are
            // published
            space.events
                .videoTrackPublications
                .filter { $0.participant.isLocal }
                .map(\.participant.connectionID),
            // We only want to know when our own tracks are
            // published
            space.events
                .videoTrackUnpublications
                .filter { $0.participant.isLocal }
                .map(\.participant.connectionID)
        )
        .sink(receiveValue: { [weak self] (connectionID: Participant.ConnectionID) in
            guard let self = self else { return }

            self.snapshot.upsertParticipant(
                connectionID
            )
        })
        .store(in: &cancellables)

        /// Each participant leaving will cause the applicable cell
        /// to be removed.
        space.events
            .participantLeft
            .map(\.participant.connectionID)
            .sink(receiveValue: { [weak self] (connectionID: Participant.ConnectionID) in
                guard let self = self else { return }

                self.snapshot.removeParticipant(
                    connectionID
                )
            })
            .store(in: &cancellables)
    }

    func tearDownEventHandlers() {
        /// Tear down observers
        cancellables.forEach { $0.cancel() }
    }

    // MARK: - Join space handling

    func joinSpace() {
        setupEventHandlers()

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

        tearDownEventHandlers()
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
