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
        ParticipantVideoViewItem
>

/// We'll also use a typealias to refer to the snapshot
typealias ParticipantsSnapshot = NSDiffableDataSourceSnapshot<
    Section,
        ParticipantVideoViewItem
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
