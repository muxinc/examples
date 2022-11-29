//
//  Created for MuxSpacesUIKit.
//  
//  Copyright © 2022 Mux, Inc.
//  Licensed under the MIT License.
//

import Combine
import UIKit

import MuxSpaces

// MARK: - Space View Model

extension SpaceViewController {

    class ViewModel {

        // MARK: Participants Snapshot

        /// For more about the @Published property wrapper
        /// see [here](https://developer.apple.com/documentation/combine/published)
        @Published var snapshot: ParticipantsSnapshot

        // MARK: Space

        /// The space the app is joining
        var space: Space

        // MARK: Published Tracks

        /// If the app publishes audio or video tracks,
        /// they will be set here
        var publishedAudioTrack: AudioTrack?
        var publishedVideoTrack: VideoTrack?

        // MARK: Initialization

        init(space: Space) {
            self.space = space
            self.snapshot = ParticipantsSnapshot.makeEmpty()
        }

        // MARK: Setup Snapshot Updates

        func setupSnapshotUpdates(
            for dataSource: ParticipantsDataSource
        ) -> AnyCancellable {
            return $snapshot
                .sink { dataSource.apply($0) }
        }

        // MARK: Fetch Most Recent Participant State

        func participant(
            from connectionID: Participant.ConnectionID
        ) -> Participant? {
            if let localParticipant = space.localParticipant {
                return (
                    [localParticipant] + space.remoteParticipants
                ).filter { $0.connectionID == connectionID }.first
            } else {
                return space.remoteParticipants
                    .filter { $0.connectionID == connectionID }.first
            }
        }

        // MARK: Update Participant Cell

        func configure(
            _ cell: ParticipantVideoCell,
            indexPath: IndexPath,
            connectionID: Participant.ConnectionID
        ) {
            guard let participant = participant(
                from: connectionID
            ) else {
                print("No Participant!")
                return
            }

            cell.setup()

            if let track = participant.videoTracks.values.first {
                cell.update(
                    participantID: participant.id,
                    videoTrack: track
                )
            } else {
                cell.update(
                    participantID: participant.id
                )
            }
        }
    }
}
