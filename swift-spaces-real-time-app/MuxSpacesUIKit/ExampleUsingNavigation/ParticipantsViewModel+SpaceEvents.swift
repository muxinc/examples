//
//  Created for MuxSpacesUIKit.
//  
//  Copyright © 2023 Mux, Inc.
//  Licensed under the MIT License.
//

import Foundation

import MuxSpaces

extension ParticipantsViewModel {

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

        let audioOptions = AudioCaptureOptions()

        self.audioCaptureOptions = audioOptions

        self.publishedAudioTrack = space.makeMicrophoneCaptureAudioTrack(
            options: audioOptions
        )

        let cameraOptions = CameraCaptureOptions(
            specifier: self.frontFacingCamera ? .position(.front) : .position(.back)
        )

        self.cameraCaptureOptions = cameraOptions

        self.publishedVideoTrack = space.makeCameraCaptureVideoTrack(
            options: cameraOptions
        )

        space.publishTrack(
            self.publishedAudioTrack!
        ) { error in
            self.audioPublishError = error
        }

        space.publishTrack(
            self.publishedVideoTrack!
        ) { error in
            self.videoPublishError = error
        }
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
        if var item = participantItems[event.participant.id] {
            item.update(event: event)
            print(item)
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
        if var item = participantItems[event.participant.id] {
            item.update(event: event)
            print(item)
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
        if var item = participantItems[event.participant.id] {
            item.update(event: event)
            participantItems[event.participant.id] = item
        }
    }

    func handle(
        event: Space.Event.VideoTrackPublishedEvent
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
        event: Space.Event.VideoTrackUnpublishedEvent
    ) {
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
            let inactiveSpeakerIDs = participantItems
                .values
                .filter { $0.isActiveSpeaker }
                .map(\.participant.id)

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

