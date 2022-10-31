//
//  ProcessInfo+EnvironmentVariables.swift
//

import Foundation

extension ProcessInfo {

    /// Set the Mux Spaces token as an environment variable to try
    /// out the app. See [here](https://developer.apple.com/documentation/xcode/customizing-the-build-schemes-for-a-project?changes=_8) for step-by-step directions.
    var spacesToken: String {
        environment[
            "MUX_SPACES_TOKEN"
        ] ?? ""
    }

}
