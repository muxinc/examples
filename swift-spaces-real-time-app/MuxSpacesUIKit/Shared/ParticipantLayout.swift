//
//  Created for MuxSpacesUIKit.
//
//  Copyright © 2022 Mux, Inc.
//  Licensed under the MIT License.
//

import AVFoundation
import UIKit

class ParticipantLayout: UICollectionViewCompositionalLayout {

    static func make() -> UICollectionViewCompositionalLayout {
        return UICollectionViewCompositionalLayout { (sectionIdentifier: Int, env: NSCollectionLayoutEnvironment) in

            switch sectionIdentifier {
            case Section.participants.rawValue:
                /// Total size our collection view has to work with
                let contentSize = env.container.effectiveContentSize

                /// Split into content area into quarters
                let contentSizeSplitIntoQuarters = contentSize.applying(
                    CGAffineTransform(
                        scaleX: 0.5,
                        y: 0.5
                    )
                )

                let aspectRatio = CGSize(
                    width: 16,
                    height: 9
                )

                let rectRespectingAspectRatio = AVMakeRect(
                    aspectRatio: aspectRatio,
                    insideRect: CGRect(
                        origin: .zero,
                        size: contentSizeSplitIntoQuarters
                    ).inset(
                        by: UIEdgeInsets(
                            top: 5, left: 5, bottom: 5, right: 5
                        )
                    )
                )

                let itemSize = NSCollectionLayoutSize(
                    widthDimension: .absolute(
                        rectRespectingAspectRatio.width
                    ),
                    heightDimension: .absolute(
                        rectRespectingAspectRatio.height
                    )
                )
                let item = NSCollectionLayoutItem(
                    layoutSize: itemSize
                )
                item.contentInsets = NSDirectionalEdgeInsets(
                    top: 5,
                    leading: 5,
                    bottom: 5,
                    trailing: 5
                )

                let groupSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0),
                    heightDimension: .absolute(
                        (rectRespectingAspectRatio.height)
                    )
                )
                let group = NSCollectionLayoutGroup.horizontal(
                    layoutSize: groupSize,
                    subitems: [item]
                )
                group.contentInsets = NSDirectionalEdgeInsets(
                    top: 10,
                    leading: 10,
                    bottom: 10,
                    trailing: 10
                )
                return NSCollectionLayoutSection(group: group)
            default:
                return nil
            }
        }
    }
}
