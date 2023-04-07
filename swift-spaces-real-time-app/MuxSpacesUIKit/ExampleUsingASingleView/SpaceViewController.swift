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

    var participantsView: UICollectionView

    var joinSpaceButton: UIButton

    override init(
        nibName nibNameOrNil: String?,
        bundle nibBundleOrNil: Bundle?
    ) {
        self.participantsView = UICollectionView(
            frame: .zero,
            collectionViewLayout: ParticipantLayout.make()
        )
        self.joinSpaceButton = UIButton(
            frame: .zero
        )

        super.init(
            nibName: nibNameOrNil,
            bundle: nibBundleOrNil
        )

        let action = UIAction { [weak self] _ in

            guard let self else {
                return
            }

            self.joinSpaceButton.isEnabled = false
            self.joinSpace()
        }

        self.joinSpaceButton.addAction(
            action,
            for: .touchUpInside
        )
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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

    lazy var dataSource: UICollectionViewDiffableDataSource<
        Section,
            Participant.ID
    > = setupParticipantsDataSource()

    func setupParticipantsDataSource() -> UICollectionViewDiffableDataSource<
        Section,
            Participant.ID
    > {
        let participantVideoCellRegistration = UICollectionView
            .CellRegistration<
                SpaceParticipantVideoCell,
                    Participant.ID
        >(
            handler: viewModel.configureSpaceParticipantVideo(_:indexPath:participantID:)
        )

        let dataSource = UICollectionViewDiffableDataSource<
            Section,
                Participant.ID
        >(
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
            .$snapshot
            .sink { self.dataSource.apply($0) }
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
