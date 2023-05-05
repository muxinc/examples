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
    @Published var snapshot: NSDiffableDataSourceSnapshot<
        Section,
            Participant.ID
    >

    // MARK: Participants View

    @Published var isParticipantsViewHidden: Bool = true

    // MARK: Display Error

    @Published var shouldDisplayError: Error? = nil

    // MARK: Space

    /// The space the app is joining
    var space: Space

    // MARK: Local Track Options

    var audioCaptureOptions: MuxSpaces.AudioCaptureOptions?
    var cameraCaptureOptions: MuxSpaces.CameraCaptureOptions?

    // MARK: Published Tracks

    /// If the app publishes audio or video tracks,
    /// they will be set here
    var publishedAudioTrack: AudioTrack?
    var publishedVideoTrack: VideoTrack?

    // MARK: Initialization

    init(space: Space) {
        self.space = space
        self.snapshot = NSDiffableDataSourceSnapshot<
            Section,
                Participant.ID
        >()
        self.snapshot.appendSections([.participants])
        self.audioCaptureOptions = AudioCaptureOptions()
        self.cameraCaptureOptions = CameraCaptureOptions()
    }

    // MARK: Setup Snapshot Updates

    func setupSnapshotUpdates(
        for dataSource: UICollectionViewDiffableDataSource<
            Section,
                Participant.ID
        >
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
            displayName: participant.displayName,
            videoTrack: participant.videoTracks.values.first
        )
    }

}
