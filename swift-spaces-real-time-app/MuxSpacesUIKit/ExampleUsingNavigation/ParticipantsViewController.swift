//
//  Created for MuxSpacesUIKit.
//
//  Copyright © 2022 Mux, Inc.
//  Licensed under the MIT License.
//

import Foundation
import UIKit
import MuxSpaces

import Combine

class ParticipantsViewController: UIViewController {

    // TODO: Dynamic layouts based on # of participants
    var participantsView: UICollectionView
    var dataSource: ParticipantsDataSource?

    var viewModel: ParticipantsViewModel

    var cancellables: Set<AnyCancellable> = []

    // MARK: - Initialization

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("\(#function) is not available.")
    }

    init(
        space: Space,
        audioCaptureOptions: AudioCaptureOptions?,
        cameraCaptureOptions: CameraCaptureOptions?
    ) {
        self.viewModel = ParticipantsViewModel(
            space: space,
            audioCaptureOptions: audioCaptureOptions,
            cameraCaptureOptions: cameraCaptureOptions
        )
        self.participantsView = UICollectionView(
            frame: .zero,
            collectionViewLayout: ParticipantLayout.make()
        )
        super.init(nibName: nil, bundle: nil)
    }

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        setupParticipantsView()

        let participantVideoCellRegistration = UICollectionView.CellRegistration<
            ParticipantVideoCell,
                ParticipantVideoViewItem
        > { cell, indexPath, itemIdentifier in
            self.viewModel.configure(
                cell,
                indexPath: indexPath,
                participantItem: itemIdentifier
            )
        }

        let dataSource = ParticipantsDataSource(
            collectionView: participantsView
        ) { (collectionView: UICollectionView, indexPath: IndexPath, item: ParticipantVideoViewItem) -> UICollectionViewCell? in
            return collectionView.dequeueConfiguredReusableCell(
                using: participantVideoCellRegistration,
                for: indexPath,
                item: item
            )
        }

        participantsView.dataSource = dataSource

        self.dataSource = dataSource

        let menu = publishingActionsMenu()

        let actionsBarButton = UIBarButtonItem(
            title: menu.title,
            image: nil,
            primaryAction: nil,
            menu: menu
        )
        actionsBarButton.menu = menu
        navigationItem.rightBarButtonItem = actionsBarButton

        viewModel
            .space
            .events
            .all
            .sink { event in
                self.viewModel.handle(event: event)
            }
            .store(in: &cancellables)

        viewModel
            .joinAndConfigureUpdates(for: dataSource)
            .store(in: &cancellables)

        viewModel
            .$participantItems
            .sink { trackState in
                actionsBarButton.menu = self.publishingActionsMenu()
            }
            .store(in: &cancellables)
    }

    override func viewWillDisappear(_ animated: Bool) {
        self.viewModel.space.leave()
        self.cancellables.forEach { $0.cancel() }
        self.dataSource = nil
        super.viewWillDisappear(animated)
    }

    func setupParticipantsView() {
        participantsView.translatesAutoresizingMaskIntoConstraints = false

        participantsView.backgroundColor = .systemGroupedBackground

        view.addSubview(participantsView)

        view.addConstraints([
            view.safeAreaLayoutGuide.leadingAnchor.constraint(
                equalTo: participantsView.leadingAnchor
            ),
            view.safeAreaLayoutGuide.trailingAnchor.constraint(
                equalTo: participantsView.trailingAnchor
            ),
            view.topAnchor.constraint(
                equalTo: participantsView.topAnchor
            ),
            view.bottomAnchor.constraint(
                equalTo: participantsView.bottomAnchor
            ),
        ])
    }

    func publishingActionsMenu() -> UIMenu {

        // TODO: Add actions for unpublishing individual tracks
        let unpublishAllTracksAction = UIAction(
            title: NSLocalizedString(
                "Unpublish All Tracks",
                comment: "Unpublish all tracks action title"
            )
        ) { [weak self] _ in
            guard let self = self else { return }
            self.viewModel.space.unpublishAllTracks()
        }

        let toggleAudioMuteAction = UIAction(
            title: NSLocalizedString(
                "Toggle Audio Mute",
                comment: "Toggle audio mute action title"
            ),
            handler: { [weak self] _ in
                guard let self = self else { return }
                self.viewModel.toggleAudioMute()
            }
        )

        let toggleVideoMuteAction = UIAction(
            title: NSLocalizedString(
                "Toggle Video Mute",
                comment: "Toggle video mute action title"
            ),
            handler: { [weak self] _ in
                guard let self = self else { return }
                self.viewModel.toggleVideoMute()
            }
        )

        var actions = [
            toggleAudioMuteAction,
            toggleVideoMuteAction,
            unpublishAllTracksAction
        ]

        for remoteAudioTrack in viewModel.participantItems.flatMap({ (key: Participant.ID, value: ParticipantVideoViewItem) in value.participant.audioTracks.values }) {
            let silenceAction = UIAction(
                title: "Silence Track \(remoteAudioTrack.name)"
            ) { [weak self] _ in
                guard let self = self else { return }
                self.viewModel.space.silence(
                    remoteAudioTrack
                )
            }
            actions.append(silenceAction)

            let unsilenceAction = UIAction(
                title: "Unsilence Track \(remoteAudioTrack.name)"
            ) { [weak self] _ in
                guard let self = self else { return }
                self.viewModel.space.unsilence(
                    remoteAudioTrack
                )
            }
            actions.append(unsilenceAction)
        }

        return UIMenu(
            title: NSLocalizedString(
                "Participant Actions",
                comment: "Participant actions menu title"
            ),
            children: actions
        )
    }
}
