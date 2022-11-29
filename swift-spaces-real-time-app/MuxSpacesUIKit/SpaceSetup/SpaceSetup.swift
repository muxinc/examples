//
//  Created for MuxSpacesUIKit.
//
//  Copyright © 2022 Mux, Inc.
//  Licensed under the MIT License.
//

import Foundation

import MuxSpaces

fileprivate var space: Space? = setupSpace()

struct SpaceSetupError: Error { }

func currentSpace() throws -> Space {
    if let space {
        return space
    } else {
        throw SpaceSetupError()
    }
}

func setupSpace(
    _ processInfo: ProcessInfo = .processInfo
) -> Space? {
    let token = processInfo.spacesToken

    // Check that the token is not empty
    // before proceeding
    guard !token.isEmpty else {
        return nil
    }

    // Initialize a Space with a pre-generated token
    guard let space = try? Space(
        token: token
    ) else {
        return nil
    }

    return space
}
