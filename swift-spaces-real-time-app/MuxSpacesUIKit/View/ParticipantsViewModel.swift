//
//  ParticipantsViewModel.swift
//

import Combine
import UIKit

import MuxSpaces

class ParticipantsViewModel {
    
    var space: Space

    @Published var snapshot: ParticipantsSnapshot

    var cancellables: Set<AnyCancellable> = []

    var publishedAudioTrack: AudioTrack?
    var publishedVideoTrack: VideoTrack?

    var audioCaptureOptions: AudioCaptureOptions?
    var videoCaptureOptions: CameraCaptureOptions?

    // MARK: - Initialization

    init(
        space: Space,
        audioCaptureOptions: AudioCaptureOptions?,
        videoCaptureOptions: CameraCaptureOptions?
    ) {
        self.space = space
        self.audioCaptureOptions = audioCaptureOptions
        self.videoCaptureOptions = videoCaptureOptions

        self.snapshot = ParticipantsSnapshot.make()

        setupEventHandlers()
    }

    deinit {
        cancellables.forEach { $0.cancel() }
    }

    // MARK: - Setup Observers on Space State Updates

    func setupEventHandlers() {
        /// Setup observers that will update your views state
        /// based on events that are produced by the space
        ///
        space
            .events
            .joinSuccesses
            .sink { [weak self] _ in
                guard let self = self else {
                    return
                }

                self.handleJoinSuccess()
            }
            .store(in: &cancellables)

        Combine.Publishers.Merge5(
            /// Participant joined events trigger a new
            /// cell to be added for each new participant
            space.events
                .participantJoined
                .map(\.participant.connectionID),
            /// When the SDK subscribes to a new video track,
            /// the participants video becomes available to display
            space.events
                .videoTrackSubscriptions
                .map(\.participant.connectionID),
            /// When the SDK unsubscribes from a video track,
            /// the participants video should be taken down
            /// this update is handled in ParticipantsViewModel
            space.events
                .videoTrackUnsubscriptions
                .map(\.participant.connectionID),
            // We only want to know when our own tracks are
            // published
            space.events
                .videoTrackPublications
                .filter { $0.participant.isLocal }
                .map(\.participant.connectionID),
            // We only want to know when our own tracks are
            // published
            space.events
                .videoTrackUnpublications
                .filter { $0.participant.isLocal }
                .map(\.participant.connectionID)
        )
        .sink(receiveValue: { [weak self] (connectionID: Participant.ConnectionID) in
            guard let self = self else { return }

            self.snapshot.upsertParticipant(
                connectionID
            )
        })
        .store(in: &cancellables)

        /// Each participant leaving will cause the applicable cell
        /// to be removed.
        space.events
            .participantLeft
            .map(\.participant.connectionID)
            .sink(receiveValue: { [weak self] (connectionID: Participant.ConnectionID) in
                guard let self = self else { return }

                self.snapshot.removeParticipant(
                    connectionID
                )
            })
            .store(in: &cancellables)
    }

    func configureUpdates(
        for dataSource: ParticipantsDataSource
    ) {
        $snapshot
            .sink { dataSource.apply($0) }
            .store(in: &cancellables)
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
