//
//  Created for MuxSpacesUIKit.
//  
//  Copyright © 2022 Mux, Inc.
//  Licensed under the MIT License.
//

import UIKit

extension UIViewController {

    // MARK: Alert Presentation Handlers

    @objc func displayJoinSpaceErrorAlert(
        _ error: Error? = nil
    ) {
        let message = error.map {
            NSLocalizedString(
                "Couldn't join space. SDK Error Description: \($0.localizedDescription)",
                comment: "Join space error alert message"
            )
        } ?? NSLocalizedString(
            "Couldn't join space.",
            comment: "Join space error alert message"
        )

        displayErrorAlert(
            NSLocalizedString(
                "Couldn't Join Space",
                comment: "Join space error alert title"
            ),
            message
        )
    }

    @objc func displaySpaceSetupErrorAlert() {
        displayErrorAlert(
            NSLocalizedString(
                "Couldn't Setup Space",
                comment: "Setup space error alert title"
            ),
            NSLocalizedString(
                "Please provide a valid Spaces JWT using the MUX_SPACES_TOKEN key",
                comment: "Setup space error alert message"
            )
        )
    }

    @objc func displayErrorAlert(
        _ title: String,
        _ message: String
    ) {
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )

        alert.addAction(
            UIAlertAction(
                title: NSLocalizedString(
                    "OK",
                    comment: "Error alert confirmatory action"
                ),
                style: .default
            )
        )

        self.present(
            alert,
            animated: true
        )
    }

}
