//
//  Created for MuxSpacesUIKit.
//  
//  Copyright © 2022 Mux, Inc.
//  Licensed under the MIT License.
//

import UIKit

import MuxSpaces

class WelcomeViewController: UITableViewController {

    var space: Space?

    func setupSpace() -> Space? {
        let token = ProcessInfo.processInfo.spacesToken

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

        self.space = space

        return space
    }

    override func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {
        guard let space = self.space ?? setupSpace() else {
            self.displaySpaceSetupErrorAlert()
            return
        }

        if indexPath.section == 0 && indexPath.row == 0 {
            let joinSpaceViewController = JoinSpaceViewController.make(
                space: space
            )
            
            navigationController?.pushViewController(
                joinSpaceViewController,
                animated: true
            )

        } else if indexPath.section == 0 && indexPath.row == 1 {
            let spaceViewController = SpaceViewController.make(
                space: space
            )

            navigationController?.pushViewController(
                spaceViewController,
                animated: true
            )
        }
    }

}
