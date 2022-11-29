//
//  Created for MuxSpacesUIKit.
//  
//  Copyright © 2022 Mux, Inc.
//  Licensed under the MIT License.
//

import Combine
import UIKit

import MuxSpaces

class SpaceViewController: UIViewController {

    @IBOutlet var participantsView: UICollectionView!

    @IBOutlet var joinSpaceButton: UIButton!

    lazy var dataSource: ParticipantsDataSource? = setupParticipantsDataSource()

    var viewModel: ViewModel

    var space: Space {
        viewModel.space
    }

    var cancellables: Set<AnyCancellable> = []

    // MARK: Initialization

    static func make(
        space: Space
    ) -> SpaceViewController {
        return UIStoryboard(
            name: "Main",
            bundle: .main
        )
        .instantiateViewController(
            identifier: "SpaceViewController",
            creator: { coder in
                SpaceViewController(
                    coder: coder,
                    space: space
                )
            }
        )
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("\(#function) is not available.")
    }

    required init?(
        coder: NSCoder,
        space: Space
    ) {
        self.viewModel = ViewModel(
            space: space
        )
        super.init(coder: coder)
    }

    // MARK: View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        participantsView.isHidden = true

        setupParticipantsView()
    }

    // MARK: UI Setup

    func setupParticipantsDataSource() -> ParticipantsDataSource {
        let participantVideoCellRegistration = UICollectionView
            .CellRegistration<
                ParticipantVideoCell,
                    Participant.ConnectionID
        >(
            handler: viewModel.configure(_:indexPath:connectionID:)
        )

        let dataSource = ParticipantsDataSource(
            collectionView: participantsView
        ) { (collectionView: UICollectionView, indexPath: IndexPath, item: Participant.ConnectionID) -> UICollectionViewCell? in
            return collectionView.dequeueConfiguredReusableCell(
                using: participantVideoCellRegistration,
                for: indexPath,
                item: item
            )
        }

        viewModel
            .setupSnapshotUpdates(for: dataSource)
            .store(in: &cancellables)

        return dataSource
    }

    func setupParticipantsView() {
        participantsView.setCollectionViewLayout(
            ParticipantLayout.make(),
            animated: false
        )

        self.dataSource = setupParticipantsDataSource()
    }

    // MARK: UI Action Handlers

    @IBAction @objc func joinSpaceButtonDidTouchUpInside(
        _ sender: UIButton
    ) {

        guard joinSpaceButton == sender else {
            print("""
                Unexpected sender received by join space handler.
                This should be the join space UIButton.
            """
            )
            return
        }

        joinSpaceButton.isEnabled = false
        self.joinSpace()
    }
}

// MARK: - Space View Model

extension SpaceViewController {

    class ViewModel {
        var space: Space

        @Published var snapshot: ParticipantsSnapshot

        var publishedAudioTrack: AudioTrack?
        var publishedVideoTrack: VideoTrack?

        init(
            space: Space
        ) {
            self.space = space
            self.snapshot = ParticipantsSnapshot.make()
        }

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

        // MARK: - Update Participant Cell

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

extension SpaceViewController.ViewModel: SpaceController {
    var audioCaptureOptions: MuxSpaces.AudioCaptureOptions? {
        return AudioCaptureOptions()
    }

    var cameraCaptureOptions: MuxSpaces.CameraCaptureOptions? {
        return CameraCaptureOptions()
    }

    func upsertParticipant(
        _ connectionID: Participant.ConnectionID
    ) {
        self.snapshot.upsertParticipant(
            connectionID
        )
    }

    func removeParticipant(
        _ connectionID: Participant.ConnectionID
    ) {
        self.snapshot.removeParticipant(
            connectionID
        )
    }

    func resetSnapshot() {
        self.snapshot = ParticipantsSnapshot.make()
    }
}

// MARK: - Space Setup

extension SpaceViewController {

    func joinSpace() {
        // Setup an event handler for joining the space
        // successfully
        viewModel.space
            .events
            .joinSuccesses
            .receive(on: DispatchQueue.main)
            .map { _ in return false }
            .assign(
                to: \.isHidden,
                on: participantsView
            )
            .store(in: &cancellables)

        viewModel.space
            .events
            .joinSuccesses
            .receive(on: DispatchQueue.main)
            .map { _ in return true }
            .assign(
                to: \.isHidden,
                on: joinSpaceButton
            )
            .store(in: &cancellables)

        // Setup an event handler in case there is an error
        // when joining the space
        viewModel.space
            .events
            .joinFailures
            .sink { [weak self] joinError in

                guard let self = self else { return }

                self.displayJoinSpaceErrorAlert()
            }
            .store(in: &cancellables)

        // We're all setup, lets join the space!
        let dataSourceCancellables = viewModel.joinSpace()

        cancellables.formUnion(dataSourceCancellables)
    }

}
