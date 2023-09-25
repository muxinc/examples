//
//  ProcessInfo+Mux.swift
//  SwiftDataLibraryInstallation
//

import Foundation

public extension ProcessInfo {
    var environmentKey: String? {
        guard let value = environment["ENV_KEY"],
                !value.isEmpty else {
            return nil
        }

        return value
    }

    var playbackID: String? {
        guard let value = environment["PLAYBACK_ID"],
                !value.isEmpty else {
            return nil
        }

        return value
    }
}
