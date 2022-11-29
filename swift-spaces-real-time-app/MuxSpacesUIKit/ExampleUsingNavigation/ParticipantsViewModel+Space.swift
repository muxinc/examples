//
//  Created for MuxSpacesUIKit.
//
//  Copyright © 2022 Mux, Inc.
//  Licensed under the MIT License.
//

import Combine
import Foundation
import MuxSpaces

/// See SpaceController.swift
extension ParticipantsViewModel: SpaceController {
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
