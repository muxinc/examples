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

    lazy var viewModel = SpaceViewModel(
        space: AppDelegate.space
    )

    // MARK: View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        /// Setup participants view with a custom layout and
        /// configure its backing data source
        setupParticipantsView()
    }

    override func viewWillDisappear(_ animated: Bool) {

        viewModel.leaveSpace()

        cancellables.forEach { $0.cancel() }

        super.viewWillDisappear(animated)
    }

    // MARK: UI Setup

    lazy var dataSource: ParticipantsDataSource = setupParticipantsDataSource()

    func setupParticipantsDataSource() -> ParticipantsDataSource {
        let participantVideoCellRegistration = UICollectionView
            .CellRegistration<
                SpaceParticipantVideoCell,
                    Participant.ID
        >(
            handler: viewModel.configureSpaceParticipantVideo(_:indexPath:participantID:)
        )

        let dataSource = ParticipantsDataSource(
            collectionView: participantsView
        ) { (collectionView: UICollectionView, indexPath: IndexPath, item: Participant.ID) -> UICollectionViewCell? in
            return collectionView.dequeueConfiguredReusableCell(
                using: participantVideoCellRegistration,
                for: indexPath,
                item: item
            )
        }

        participantsView.dataSource = dataSource

        return dataSource
    }

    func setupParticipantsView() {
        participantsView.isHidden = true

        viewModel
            .setupSnapshotUpdates(for: dataSource)
            .store(in: &cancellables)

        participantsView.setCollectionViewLayout(
            ParticipantLayout.make(),
            animated: false
        )
    }
}

// MARK: - Space Setup

extension SpaceViewController {

    func joinSpace() {
        // Setup an event handler for joining the space
        // successfully
        viewModel.$isParticipantsViewHidden
            .assign(
                to: \.isHidden,
                on: participantsView
            )
            .store(in: &cancellables)

        viewModel.$isJoinSpaceButtonHidden
            .assign(
                to: \.isHidden,
                on: joinSpaceButton
            )
            .store(in: &cancellables)

        // Setup an event handler in case there is an error
        // when joining the space
        viewModel.$shouldDisplayError
            .compactMap { $0 }
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
