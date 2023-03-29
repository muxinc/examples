//
//  Created for MuxSpacesUIKit.
//  
//  Copyright © 2022 Mux, Inc.
//  Licensed under the MIT License.
//

import Combine
import Foundation

import MuxSpaces

extension SpaceViewModel: SpaceController {
    // MARK: - Setup Observers on Space State Updates

    func setupEventHandlers() -> Set<AnyCancellable> {

        var cancellables: Set<AnyCancellable> = []

        /// Setup observers that will update your views state
        /// based on events that are produced by the space
        ///
        space
            .events
            .joinSuccess.map { _ in return false }
            .assign(to: \.isParticipantsViewHidden, on: self)
            .store(in: &cancellables)

        space
            .events
            .joinSuccess.map { _ in return true }
            .assign(to: \.isJoinSpaceButtonHidden, on: self)
            .store(in: &cancellables)

        space
            .events
            .joinFailure.map { $0.error }
            .assign(to: \.shouldDisplayError, on: self)
            .store(in: &cancellables)

        space
            .events
            .joinSuccess
            .sink { [weak self] _ in
                guard let self = self else {
                    return
                }

                self.handleJoinSuccess()
            }
            .store(in: &cancellables)

        Combine.Publishers.Merge6(
            /// Joining a space successfully triggers a
            /// placeholder cell to be added for the local participant
            space.events
                .joinSuccess
                .map(\.localParticipant.id),
            /// Participant joined events trigger a new
            /// cell to be added for each new participant
            space.events
                .participantJoined
                .map(\.participant.id),
            /// When the SDK subscribes to a new video track,
            /// the participants video becomes available to display
            space.events
                .videoTrackSubscribed
                .map(\.participant.id),
            /// When the SDK unsubscribes from a video track,
            /// the participants video should be taken down
            /// this update is handled in ParticipantsViewModel
            space.events
                .videoTrackUnsubscribed
                .map(\.participant.id),
            // We only want to know when our own tracks are
            // published
            space.events
                .videoTrackPublished
                .filter { $0.participant.isLocal }
                .map(\.participant.id),
            // We only want to know when our own tracks are
            // published
            space.events
                .videoTrackUnpublished
                .filter { $0.participant.isLocal }
                .map(\.participant.id)
        )
        .sink(receiveValue: { [weak self] (id: Participant.ID) in
            guard let self = self else { return }

            self.upsertParticipant(
                id
            )
        })
        .store(in: &cancellables)

        /// Each participant leaving will cause the applicable cell
        /// to be removed.
        space.events
            .participantLeft
            .map(\.participant.id)
            .sink(receiveValue: { [weak self] (id: Participant.ID) in
                guard let self = self else { return }

                self.removeParticipant(
                    id
                )
            })
            .store(in: &cancellables)

        return cancellables
    }

    func upsertParticipant(
        _ participantID: Participant.ID
    ) {
        self.snapshot.upsertParticipant(
            participantID
        )
    }

    func removeParticipant(
        _ participantID: Participant.ID
    ) {
        self.snapshot.removeParticipant(
            participantID
        )
    }

    func resetSnapshot() {
        self.snapshot = ParticipantsSnapshot.makeEmpty()
    }
}
