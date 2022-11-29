//
//  ParticipantsViewModel+Space.swift
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
        self.snapshot = ParticipantsSnapshot.make()
    }
}
