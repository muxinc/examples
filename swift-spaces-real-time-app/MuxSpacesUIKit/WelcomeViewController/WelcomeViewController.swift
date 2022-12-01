//
//  Created for MuxSpacesUIKit.
//  
//  Copyright © 2022 Mux, Inc.
//  Licensed under the MIT License.
//

import UIKit

import MuxSpaces

class WelcomeViewController: UITableViewController {
    override func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {
        if indexPath.section == 0 && indexPath.row == 0 {

            let joinSpaceViewController = JoinSpaceViewController(
                space: AppDelegate.space
            )
            
            navigationController?.pushViewController(
                joinSpaceViewController,
                animated: true
            )

        } else if indexPath.section == 0 && indexPath.row == 1 {
            let spaceViewController = UIStoryboard(
                name: "Main",
                bundle: .main
            )
            .instantiateViewController(
                identifier: "SpaceViewController"
            )

            spaceViewController.title = NSLocalizedString(
                "After joining tap Back to leave space",
                comment: "Leave space prompt"
            )

            navigationController?.pushViewController(
                spaceViewController,
                animated: true
            )
        }
    }
}
