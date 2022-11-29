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

    // MARK: IBOutlets for Storyboard

    @IBOutlet var participantsView: UICollectionView!

    @IBOutlet var joinSpaceButton: UIButton!

    // MARK: IBAction for Storyboard

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

    // MARK: Subscription related state

    var cancellables: Set<AnyCancellable> = []

    // MARK: View Model

    var viewModel: ViewModel = ViewModel(space: try! currentSpace())

    // MARK: View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        setupParticipantsView()
    }

    override func viewWillDisappear(_ animated: Bool) {

        viewModel.space.leave()

        cancellables.forEach { $0.cancel() }

        super.viewWillDisappear(animated)
    }

    // MARK: UI Setup

    lazy var dataSource: ParticipantsDataSource? = setupParticipantsDataSource()

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
        participantsView.isHidden = true

        participantsView.setCollectionViewLayout(
            ParticipantLayout.make(),
            animated: false
        )

        self.dataSource = setupParticipantsDataSource()
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
        self.snapshot = ParticipantsSnapshot.makeEmpty()
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
            .map { _ in return false }
            .assign(
                to: \.isHidden,
                on: participantsView
            )
            .store(in: &cancellables)

        viewModel.space
            .events
            .joinSuccesses
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
