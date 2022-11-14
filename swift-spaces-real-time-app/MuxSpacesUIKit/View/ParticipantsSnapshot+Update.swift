//
//  ParticipantsSnapshot+Update.swift
//

import UIKit

import MuxSpaces

typealias ParticipantsSnapshot = NSDiffableDataSourceSnapshot<
    Section,
        String
>

extension ParticipantsSnapshot {

    /// Removes a participant from the snapshot and
    /// causes the collection view to delete the cell
    /// that corresponds to that participant's video
    mutating func removeParticipant(
        _ connectionID: Participant.ConnectionID
    ) {
        let deletedItems = itemIdentifiers
            .filter {
                return $0 == connectionID
            }

        deleteItems(deletedItems)
    }

    /// Updates an existing cell by removing or adding a UIView
    /// displaying the participants video.
    ///
    /// If no cell corresponding to the participant is found
    /// then adds participant along with their video if applicable.
    ///
    mutating func upsertParticipant(
        _ connectionID: Participant.ConnectionID
    ) {
        let items = itemIdentifiers
            .filter { (checkedItem: Participant.ConnectionID) in
                return checkedItem == connectionID
            }

        if items.isEmpty {
            self.appendItems(
                [
                    connectionID
                ],
                toSection: .participants
            )
        } else {
            self.reloadItems(
                [
                    connectionID
                ]
            )
        }
    }
}
