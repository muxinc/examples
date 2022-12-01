//
//  Created for MuxSpacesUIKit.
//
//  Copyright © 2022 Mux, Inc.
//  Licensed under the MIT License.
//

import UIKit

import MuxSpaces

// MARK: - Section

/// The UI we're building will only display participants and
/// their videos so there is only one section defined here
enum Section: Int {
    case participants
}

// MARK: - Typealiases

/// To help readibility, we'll use a typealias to refer to
/// the data source
typealias ParticipantsDataSource = UICollectionViewDiffableDataSource<
    Section,
        String
>

/// We'll also use a typealias to refer to the snapshot
typealias ParticipantsSnapshot = NSDiffableDataSourceSnapshot<
    Section,
        String
>

// MARK: - Constructor

extension ParticipantsSnapshot {
    /// Creates a snapshot with an empty participants section
    static func makeEmpty() -> Self {
        var snapshot = ParticipantsSnapshot()
        snapshot.appendSections(
            [.participants]
        )
        return snapshot
    }
}

// MARK: - Update Logic

extension ParticipantsSnapshot {

    // MARK: Update or Insert Participant

    /// Updates an existing cell by removing or adding a UIView
    /// displaying the participants video.
    ///
    /// If no cell corresponding to the participant is found
    /// then adds participant along with their video if applicable.
    ///
    mutating func upsertParticipant(
        _ participantID: Participant.ID
    ) {
        let items = itemIdentifiers
            .filter { (checkedItem: Participant.ID) in
                return checkedItem == participantID
            }

        if items.isEmpty {
            self.appendItems(
                [
                    participantID
                ],
                toSection: .participants
            )
        } else {
            self.reloadItems(
                [
                    participantID
                ]
            )
        }
    }

    // MARK: Remove Participant

    /// Removes a participant from the snapshot and
    /// causes the collection view to delete the cell
    /// that corresponds to that participant's video
    mutating func removeParticipant(
        _ participantID: Participant.ID
    ) {
        let deletedItems = itemIdentifiers
            .filter {
                return $0 == participantID
            }

        deleteItems(deletedItems)
    }
}
