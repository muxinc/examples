//
//  Created for MuxSpacesUIKit.
//
//  Copyright © 2022 Mux, Inc.
//  Licensed under the MIT License.
//

import Combine
import UIKit

import MuxSpaces

class ParticipantsViewModel {
    
    var space: Space

    @Published var participantItems: [Participant.ID: ParticipantVideoViewItem] = [:] {
        didSet {
            snapshot = recomputeSnapshot()
        }
    }

    @Published var snapshot: ParticipantsSnapshot

    var localParticipant: Participant? {
        participantItems.values.first {
            $0.participant.isLocal
        }?.participant
    }

    @Published var publishedAudioTrack: AudioTrack?
    @Published var publishedVideoTrack: VideoTrack?

    @Published var audioCaptureOptions: AudioCaptureOptions?
    @Published var cameraCaptureOptions: CameraCaptureOptions?

    @Published var frontFacingCamera: Bool = true

    @Published var audioPublishError: AudioTrack.PublishError?
    @Published var videoPublishError: VideoTrack.PublishError?

    // MARK: - Initialization

    init(
        space: Space,
        audioCaptureOptions: AudioCaptureOptions?,
        cameraCaptureOptions: CameraCaptureOptions?
    ) {
        self.space = space
        self.snapshot = ParticipantsSnapshot.makeEmpty()
        
        self.audioCaptureOptions = audioCaptureOptions
        self.cameraCaptureOptions = cameraCaptureOptions
    }

    func joinAndConfigureUpdates(
        for dataSource: ParticipantsDataSource
    ) -> AnyCancellable {
        space.join()

        return $snapshot
            .sink { dataSource.apply($0) }
    }

    func recomputeSnapshot() -> ParticipantsSnapshot {
        var snapshot = ParticipantsSnapshot()

        snapshot.appendSections(
            [.participants]
        )

        snapshot.appendItems(
            Array(participantItems.values),
            toSection: .participants
        )

        return snapshot
    }

    // MARK: - Update Participant Cell State

    func configure(
        _ cell: ParticipantVideoCell,
        indexPath: IndexPath,
        participantItem: ParticipantVideoViewItem
    ) {
        cell.setup()

        cell.update(
            participantID: participantItem.participant.displayName,
            videoTrack: participantItem.videoTrack,
            audioTrack: participantItem.audioTrack
        )
    }
}
