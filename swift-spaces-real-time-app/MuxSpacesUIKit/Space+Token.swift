//
//  Space+TokenGeneration.swift
//

import Foundation
import MuxSpaces

/// Set the Mux Spaces token as an environment variable to try
/// out the app. See [here](https://developer.apple.com/documentation/xcode/customizing-the-build-schemes-for-a-project?changes=_8) for step-by-step directions.
let token = ProcessInfo.processInfo.environment[
    "MUX_SPACES_TOKEN"
] ?? ""

extension Space {
    static func make() throws -> Space {
        if token.isEmpty {
            print("Please add a include Spaces JWT to try out the sample code")
        }
        
        return try Space(token: token)
    }
}

