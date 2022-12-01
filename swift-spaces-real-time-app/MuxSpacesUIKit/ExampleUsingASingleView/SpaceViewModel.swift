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

class SpaceViewModel {

    // MARK: Join Button

    @Published var isJoinSpaceButtonHidden: Bool = false

    // MARK: Participants Snapshot

    /// For more about the @Published property wrapper
    /// see [here](https://developer.apple.com/documentation/combine/published)
    @Published var snapshot: ParticipantsSnapshot

    // MARK: Participants View

    @Published var isParticipantsViewHidden: Bool = true

    // MARK: Display Error

    @Published var shouldDisplayError: Error? = nil

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
        from participantID: Participant.ID
    ) -> Participant? {
        if let localParticipant = space.localParticipant {
            return (
                [localParticipant] + space.remoteParticipants
            ).filter { $0.id == participantID }.first
        } else {
            return space.remoteParticipants
                .filter { $0.id == participantID }.first
        }
    }

    // MARK: Update Participant Cell

    func configureSpaceParticipantVideo(
        _ cell: SpaceParticipantVideoCell,
        indexPath: IndexPath,
        participantID: Participant.ID
    ) {
        guard let participant = participant(
            from: participantID
        ) else {
            print("No Participant!")
            return
        }

        cell.setup()
        cell.update(
            participantID: participant.id,
            videoTrack: participant.videoTracks.values.first
        )
    }

}
