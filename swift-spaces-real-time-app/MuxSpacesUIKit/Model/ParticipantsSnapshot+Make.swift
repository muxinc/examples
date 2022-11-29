//
//  ParticipantsSnapshot+Make.swift
//

import UIKit

extension ParticipantsSnapshot {
    static func make() -> Self {
        var snapshot = ParticipantsSnapshot()
        snapshot.appendSections(
            [.participants]
        )
        return snapshot
    }
}
