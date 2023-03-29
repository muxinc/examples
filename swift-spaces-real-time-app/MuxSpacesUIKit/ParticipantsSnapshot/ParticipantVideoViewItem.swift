//
//  Created for MuxSpacesUIKit.
//  
//  Copyright © 2023 Mux, Inc.
//  Licensed under the MIT License.
//

import Foundation

import MuxSpaces

struct ParticipantVideoViewItem {
    var participant: Participant

    var audioTrack: AudioTrack?
    var videoTrack: VideoTrack?
}

extension ParticipantVideoViewItem: Equatable, Hashable {

}

extension ParticipantVideoViewItem {

    init(
        event: Space.Event.JoinSuccessEvent
    ) {
        self.init(
            participant: event.localParticipant
        )
    }

    init(
        event: Space.Event.ParticipantJoinedEvent
    ) {
        self.init(
            participant: event.participant
        )
    }

    init(
        event: Space.Event.VideoTrackPublishedEvent
    ) {
        self.init(
            participant: event.participant,
            videoTrack: event.track
        )
    }

    init(
        event: Space.Event.AudioTrackPublishedEvent
    ) {
        self.init(
            participant: event.participant,
            audioTrack: event.track
        )
    }

    init(
        event: Space.Event.VideoTrackSubscribedEvent
    ) {
        self.init(
            participant: event.participant,
            videoTrack: event.track
        )
    }

    init(
        event: Space.Event.AudioTrackSubscribedEvent
    ) {
        self.init(
            participant: event.participant,
            audioTrack: event.track
        )
    }
}

extension ParticipantVideoViewItem {

    mutating func update(
        event: Space.Event.AudioTrackPublishedEvent
    ) {
        self.participant = event.participant

        if event.track.isLocal {
            self.audioTrack = event.track
        }
    }

    mutating func update(
        event: Space.Event.VideoTrackPublishedEvent
    ) {
        self.participant = event.participant

        if event.track.isLocal {
            self.videoTrack = event.track
        }
    }

    mutating func update(
        event: Space.Event.AudioTrackUnpublishedEvent
    ) {
        self.participant = event.participant
        self.audioTrack = nil
    }

    mutating func update(
        event: Space.Event.VideoTrackUnpublishedEvent
    ) {
        self.participant = event.participant
        self.videoTrack = nil
    }

    mutating func update(
        event: Space.Event.AudioTrackSubscribedEvent
    ) {
        self.participant = event.participant
        self.audioTrack = event.track
    }

    mutating func update(
        event: Space.Event.VideoTrackSubscribedEvent
    ) {
        self.participant = event.participant
        self.videoTrack = event.track
    }

    mutating func update(
        event: Space.Event.AudioTrackUnsubscribedEvent
    ) {
        self.participant = event.participant
        self.audioTrack = nil
    }

    mutating func update(
        event: Space.Event.VideoTrackUnsubscribedEvent
    ) {
        self.participant = event.participant
        self.videoTrack = nil
    }

    mutating func update(
        event: Space.Event.AudioTrackMutedEvent
    ) {
        self.participant = event.participant
        self.audioTrack = event.track
    }

    mutating func update(
        event: Space.Event.AudioTrackUnmutedEvent
    ) {
        self.participant = event.participant
        self.audioTrack = event.track
    }

    mutating func update(
        event: Space.Event.VideoTrackMutedEvent
    ) {
        self.participant = event.participant
        self.videoTrack = event.track
    }

    mutating func update(
        event: Space.Event.VideoTrackUnmutedEvent
    ) {
        self.participant = event.participant
        self.videoTrack = event.track
    }

}

