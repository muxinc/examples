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
            localParticipant = participantItems.first(
                where: { keyValue in
                    keyValue.value.participant.isLocal
                }
            )?.value.participant
            publishedAudioTrack = participantItems.first(
                where: { keyValue in
                    keyValue.value.participant.isLocal
                }
            )?.value.participant.audioTracks.values.first(
                where: { track in
                    track.source == .microphone
                }
            )
            publishedVideoTrack = participantItems.first(
                where: { keyValue in
                    keyValue.value.participant.isLocal
                }
            )?.value.participant.videoTracks.values.first(
                where: { track in
                    track.source == .camera
                }
            )
        }
    }

    @Published var snapshot: ParticipantsSnapshot

    @Published var localParticipant: Participant?

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
        space.join(
            options: SpaceOptions(
                displayName: "UIKitExample"
            )
        )

        return $snapshot
            .sink { dataSource.apply($0) }
    }

    func toggleAudioMute() {
        guard let publishedAudioTrack else {
            return
        }

        if publishedAudioTrack.isMuted {
            space.unmuteTrack(publishedAudioTrack)
        } else {
            space.muteTrack(publishedAudioTrack)
        }
    }

    func toggleVideoMute() {
        guard let publishedVideoTrack else {
            return
        }

        if publishedVideoTrack.isMuted {
            space.unmuteTrack(publishedVideoTrack)
        } else {
            space.muteTrack(publishedVideoTrack)
        }
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
            displayName: participantItem.participant.displayName,
            videoTrack: participantItem.videoTrack,
            audioTrack: participantItem.audioTrack
        )
    }
}
