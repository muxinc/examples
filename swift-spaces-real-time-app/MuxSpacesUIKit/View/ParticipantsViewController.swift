//
//  ParticipantsViewController.swift
//

import Foundation
import UIKit
import MuxSpaces

import Combine

enum Section: Int {
    case participants
}

typealias ParticipantsDataSource = UICollectionViewDiffableDataSource<
    Section,
        Participant.ConnectionID
>

class ParticipantsViewController: UIViewController {

    // TODO: Dynamic layouts based on # of participants
    @IBOutlet var participantsView: UICollectionView!
    var dataSource: ParticipantsDataSource?

    var viewModel: ParticipantsViewModel!

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        participantsView.setCollectionViewLayout(
            createLayout(),
            animated: false
        )

        let attendeeCellRegistration = UICollectionView.CellRegistration<
            ParticipantVideoCell,
                Participant.ConnectionID
        >(
            handler: viewModel.configure(_:indexPath:connectionID:)
        )

        let dataSource = ParticipantsDataSource(
            collectionView: participantsView
        ) { (collectionView: UICollectionView, indexPath: IndexPath, item: Participant.ConnectionID) -> UICollectionViewCell? in
            return collectionView.dequeueConfiguredReusableCell(
                using: attendeeCellRegistration,
                for: indexPath,
                item: item
            )
        }

        viewModel.configureUpdates(
            for: dataSource
        )

        self.dataSource = dataSource

        setupPublishingActionsButton()
    }

    override func viewWillDisappear(_ animated: Bool) {
        self.viewModel.leaveSpace()
        super.viewWillDisappear(animated)
    }

    var isAudioMuted: Bool = false {
        didSet {
            guard let track = self.viewModel.publishedAudioTrack else {
                print("No audio track")
                return
            }

            if isAudioMuted {
                self.viewModel.space.muteTrack(track)
            } else {
                self.viewModel.space.unmuteTrack(track)
            }
        }
    }

    var isVideoMuted: Bool = false {
        didSet {

            guard let track = self.viewModel.publishedVideoTrack else {
                print("No video track")
                return
            }

            if isVideoMuted {
                self.viewModel.space.muteTrack(track)
            } else {
                self.viewModel.space.unmuteTrack(track)
            }
        }
    }

    func setupPublishingActionsButton() {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.menu = publishingActionsMenu()
        button.showsMenuAsPrimaryAction = true
        button.setTitle(
            NSLocalizedString(
                "Participant Actions",
                comment: "Participant actions button title"
            ),
            for: .normal
        )
        button.setTitleColor(
            .systemBlue,
            for: .normal
        )
        button.isEnabled = true

        view.addSubview(button)

        view.addConstraints([
            button.centerXAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.centerXAnchor
            ),
            button.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor,
                constant: 12.0
            )
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
                self.isAudioMuted.toggle()
            }
        )

        let toggleVideoMuteAction = UIAction(
            title: NSLocalizedString(
                "Toggle Video Mute",
                comment: "Toggle video mute action title"
            ),
            handler: { [weak self] _ in
                guard let self = self else { return }
                self.isVideoMuted.toggle()
            }
        )

        return UIMenu(
            title: NSLocalizedString(
                "Participant Actions",
                comment: "Participant actions menu title"
            ),
            children: [
                toggleAudioMuteAction,
                toggleVideoMuteAction,
                unpublishAllTracksAction
            ]
        )
    }
}
