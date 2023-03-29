//
//  Created for MuxSpacesUIKit.
//
//  Copyright © 2022 Mux, Inc.
//  Licensed under the MIT License.
//

import Combine
import UIKit

import MuxSpaces

struct TrackState {
    var publishedAudioTrack: AudioTrack?
    var publishedVideoTrack: VideoTrack?

    var audioCaptureOptions: AudioCaptureOptions?
    var cameraCaptureOptions: CameraCaptureOptions?

    var audioTracks: [AudioTrack] = []
}

class ParticipantsViewModel {
    
    var space: Space

    @Published var snapshot: ParticipantsSnapshot

    @Published var trackState = TrackState(
        audioCaptureOptions: AudioCaptureOptions(),
        cameraCaptureOptions: CameraCaptureOptions()
    )

    var errorHandler: (Error?) -> () = { _ in }

    // MARK: - Initialization

    init(
        space: Space,
        audioCaptureOptions: AudioCaptureOptions?,
        cameraCaptureOptions: CameraCaptureOptions?
    ) {
        self.space = space
        self.snapshot = ParticipantsSnapshot.makeEmpty()
        
        self.trackState.audioCaptureOptions = audioCaptureOptions
        self.trackState.cameraCaptureOptions = cameraCaptureOptions
    }

    func configureUpdates(
        for dataSource: ParticipantsDataSource
    ) -> AnyCancellable {
        return $snapshot
            .sink { dataSource.apply($0) }
    }

    // MARK: - Update Participant Cell State

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

    func configure(
        _ cell: ParticipantVideoCell,
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
        cell.contentView.backgroundColor = .black

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
