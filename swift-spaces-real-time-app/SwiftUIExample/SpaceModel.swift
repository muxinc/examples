//
//  Created for SpacesSwiftUIDemo.
//  
//  Copyright © 2023 Mux, Inc.
//  Licensed under the MIT License.
//

import Combine
import Foundation

import MuxSpaces

extension Dictionary where Key == Participant.ID, Value == ParticipantVideoViewItem {
    var sortedItems: [ParticipantVideoViewItem] {
        Array(values).sorted { a, b in
            if a.participant.isLocal {
                return true
            } else {
                return false
            }
        }
    }
}

class SpaceModel: ObservableObject {
    var token: String = ProcessInfo.processInfo.spacesToken

    var space: Space?
    var cancellables: Set<AnyCancellable> = []

    @Published var hasJoined = false
    @Published var displayName = "SwiftUI Demo"

    @Published var micMuted = false
    @Published var cameraOff = false
    @Published var frontFacingCamera = true
    @Published var localMicTrack: AudioTrack?
    @Published var localCameraTrack: VideoTrack?

    @Published var audioPublishError: AudioTrack.PublishError?
    @Published var videoPublishError: VideoTrack.PublishError?

    @Published var participantItems: [Participant.ID: ParticipantVideoViewItem] = [:] {
        didSet {
            sortedParticipantItems = participantItems.sortedItems
        }
    }
    @Published var sortedParticipantItems: [ParticipantVideoViewItem] = []

    func join() {
        do {
            let space = try Space(token: self.token)
            self.space = space

            space.events.all.sink { event in
                self.handle(event: event)
            }
            .store(in: &cancellables)

            space.join(options: SpaceOptions(displayName: self.displayName))
        } catch {
            print(error.localizedDescription)
        }
    }

    func toggleMicMute() {
        guard let micTrack = self.localMicTrack else {
            print("Initialize a mic track before trying to toggle it.")
            return
        }

        if(micTrack.isMuted) {
            micMuted = false
            space?.unmuteTrack(micTrack)
        } else {
            micMuted = true
            space?.muteTrack(micTrack)
        }
    }

    func flipCamera() {
        if self.localCameraTrack != nil {
            space?.unpublishTrack(self.localCameraTrack!)
        }

        self.frontFacingCamera.toggle()

        self.localCameraTrack = space?.makeCameraCaptureVideoTrack(
            options: CameraCaptureOptions(specifier: self.frontFacingCamera ? .position(.front) : .position(.back))
        )

        space?.publishTrack(
            self.localCameraTrack!
        ) { error in
            self.videoPublishError = error
        }
    }

    func toggleCamera() {
        guard let cameraTrack = self.localCameraTrack else {
            print("Initialize a camera track before trying to toggle it.")
            return
        }

        if(cameraOff) {
            cameraOff = false
            space?.unmuteTrack(cameraTrack)
        } else {
            cameraOff = true
            space?.muteTrack(cameraTrack)
        }
    }

    func leave() {
        if (self.hasJoined) {
            space?.leave()
        }
    }
}

extension SpaceModel {
    func handle(
        event: Space.Event
    ) {
        switch event {
        case .joinSuccess(let metadata):
            handle(event: metadata)
        case .joinFailure(_):
            break
        case .disconnected(_):
            break
        case .broadcastStateChanged(_):
            break
        case .participantJoined(let metadata):
            handle(event: metadata)
        case .participantLeft(let metadata):
            handle(event: metadata)
        case .audioTrackMuted(let metadata):
            handle(event: metadata)
        case .audioTrackUnmuted(let metadata):
            handle(event: metadata)
        case .videoTrackMuted(let metadata):
            handle(event: metadata)
        case .videoTrackUnmuted(let metadata):
            handle(event: metadata)
        case .audioTrackSubscribed(let metadata):
            handle(event: metadata)
        case .audioTrackUnsubscribed(let metadata):
            handle(event: metadata)
        case .videoTrackSubscribed(let metadata):
            handle(event: metadata)
        case .videoTrackUnsubscribed(let metadata):
            handle(event: metadata)
        case .audioTrackPublished(let metadata):
            handle(event: metadata)
        case .audioTrackUnpublished(let metadata):
            handle(event: metadata)
        case .videoTrackPublished(let metadata):
            handle(event: metadata)
        case .videoTrackUnpublished(let metadata):
            handle(event: metadata)
        case .activeSpeakersChanged(let metadata):
            handle(event: metadata)
        default:
            break
        }
    }

    func handle(
        event: Space.Event.JoinSuccessEvent
    ) {
        self.participantItems[event.localParticipant.id] = ParticipantVideoViewItem(
            event: event
        )

        guard let space = self.space else {
            return
        }

        self.localMicTrack = space.makeMicrophoneCaptureAudioTrack(
            options: AudioCaptureOptions()
        )

        self.localCameraTrack = space.makeCameraCaptureVideoTrack(
            options: CameraCaptureOptions(specifier: self.frontFacingCamera ? .position(.front) : .position(.back))
        )

        space.publishTrack(
            self.localMicTrack!
        ) { error in
            self.audioPublishError = error
        }

        space.publishTrack(
            self.localCameraTrack!
        ) { error in
            self.videoPublishError = error
        }

        self.hasJoined = true
    }

    func handle(
        event: Space.Event.ParticipantJoinedEvent
    ) {
        participantItems[event.participant.id] = ParticipantVideoViewItem(
            event: event
        )
    }

    func handle(
        event: Space.Event.ParticipantLeftEvent
    ) {
        participantItems[event.participant.id] = nil
    }

    func handle(
        event: Space.Event.AudioTrackMutedEvent
    ) {
        if event.participant.isLocal {
            self.localMicTrack = event.track
        }
        if var item = participantItems[event.participant.id] {
            item.update(event: event)
            participantItems[event.participant.id] = item
        } else {
            participantItems[event.participant.id] = ParticipantVideoViewItem(
                event: event
            )
        }
    }

    func handle(
        event: Space.Event.AudioTrackUnmutedEvent
    ) {
        if event.participant.isLocal {
            self.localMicTrack = event.track
        }
        if var item = participantItems[event.participant.id] {
            item.update(event: event)
            participantItems[event.participant.id] = item
        } else {
            participantItems[event.participant.id] = ParticipantVideoViewItem(
                event: event
            )
        }
    }

    func handle(
        event: Space.Event.VideoTrackMutedEvent
    ) {
        if event.participant.isLocal {
            self.localCameraTrack = event.track
        }
        if var item = participantItems[event.participant.id] {
            item.update(event: event)
            participantItems[event.participant.id] = item
        } else {
            participantItems[event.participant.id] = ParticipantVideoViewItem(
                event: event
            )
        }
    }

    func handle(
        event: Space.Event.VideoTrackUnmutedEvent
    ) {
        if event.participant.isLocal {
            self.localCameraTrack = event.track
        }
        if var item = participantItems[event.participant.id] {
            item.update(event: event)
            participantItems[event.participant.id] = item
        } else {
            participantItems[event.participant.id] = ParticipantVideoViewItem(
                event: event
            )
        }
    }

    func handle(
        event: Space.Event.AudioTrackPublishedEvent
    ) {
        if event.participant.isLocal {
            self.localMicTrack = event.track
        }
        if var item = participantItems[event.participant.id] {
            item.update(event: event)
            participantItems[event.participant.id] = item
        } else {
            participantItems[event.participant.id] = ParticipantVideoViewItem(
                event: event
            )
        }
    }

    func handle(
        event: Space.Event.AudioTrackUnpublishedEvent
    ) {
        if event.participant.isLocal {
            self.localMicTrack = nil
        }
        if var item = participantItems[event.participant.id] {
            item.update(event: event)
            participantItems[event.participant.id] = item
        }
    }

    func handle(
        event: Space.Event.VideoTrackPublishedEvent
    ) {
        if event.participant.isLocal {
            self.localCameraTrack = event.track
        }
        if var item = participantItems[event.participant.id] {
            item.update(event: event)
            participantItems[event.participant.id] = item
        } else {
            participantItems[event.participant.id] = ParticipantVideoViewItem(
                event: event
            )
        }
    }

    func handle(
        event: Space.Event.VideoTrackUnpublishedEvent
    ) {
        if event.participant.isLocal {
            self.localCameraTrack = nil
        }
        if var item = participantItems[event.participant.id] {
            item.update(event: event)
            participantItems[event.participant.id] = item
        }
    }

    func handle(
        event: Space.Event.AudioTrackSubscribedEvent
    ) {
        if var item = participantItems[event.participant.id] {
            item.update(event: event)
            participantItems[event.participant.id] = item
        } else {
            participantItems[event.participant.id] = ParticipantVideoViewItem(
                event: event
            )
        }
    }

    func handle(
        event: Space.Event.AudioTrackUnsubscribedEvent
    ) {
        if var item = participantItems[event.participant.id] {
            item.update(event: event)
            participantItems[event.participant.id] = item
        }
    }

    func handle(
        event: Space.Event.VideoTrackSubscribedEvent
    ) {
        if var item = participantItems[event.participant.id] {
            item.update(event: event)
            participantItems[event.participant.id] = item
        } else {
            participantItems[event.participant.id] = ParticipantVideoViewItem(
                event: event
            )
        }
    }

    func handle(
        event: Space.Event.VideoTrackUnsubscribedEvent
    ) {
        precondition(event.track.hasMedia == false)

        if var item = participantItems[event.participant.id] {
            item.update(event: event)
            participantItems[event.participant.id] = item
        }
    }

    func handle(
        event: Space.Event.ActiveSpeakersChangedEvent
    ) {
        if event.activeSpeakers.isEmpty {
            let inactiveSpeakerIDs = sortedParticipantItems.filter { $0.isActiveSpeaker }.map(\.participant.id)

            for id in inactiveSpeakerIDs {
                if var item = participantItems[id] {
                    item.isActiveSpeaker = false
                    participantItems[id] = item
                }
            }
        }

        let items = Array(participantItems.values)

        for item in items {
            guard let _ = item.audioTrack else {
                continue
            }

            var modified = item
            modified.update(event: event)
            participantItems[item.participant.id] = modified
        }
    }
}
