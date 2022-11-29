//
//  ParticipantsViewModel.swift
//

import Combine
import UIKit

import MuxSpaces

class ParticipantsViewModel {
    
    var space: Space

    @Published var snapshot: ParticipantsSnapshot

    var publishedAudioTrack: AudioTrack?
    var publishedVideoTrack: VideoTrack?

    var audioCaptureOptions: AudioCaptureOptions?
    var cameraCaptureOptions: CameraCaptureOptions?

    // MARK: - Initialization

    init(
        space: Space,
        audioCaptureOptions: AudioCaptureOptions?,
        cameraCaptureOptions: CameraCaptureOptions?
    ) {
        self.space = space
        self.audioCaptureOptions = audioCaptureOptions
        self.cameraCaptureOptions = cameraCaptureOptions

        self.snapshot = ParticipantsSnapshot.make()
    }

    func configureUpdates(
        for dataSource: ParticipantsDataSource
    ) -> AnyCancellable {
        return $snapshot
            .sink { dataSource.apply($0) }
    }

    // MARK: - Update Participant Cell State

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
