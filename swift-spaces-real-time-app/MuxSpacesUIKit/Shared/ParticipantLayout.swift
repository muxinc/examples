//
//  Created for MuxSpacesUIKit.
//
//  Copyright © 2022 Mux, Inc.
//  Licensed under the MIT License.
//

import AVFoundation
import UIKit

class ParticipantLayout: UICollectionViewCompositionalLayout {

    static func computeParticipantCellSize(
        fitting rect: CGRect,
        respecting aspectRatio: CGSize
    ) -> CGRect {

        let insetRect = rect.inset(
                by: UIEdgeInsets(
                    top: 5,
                    left: 5,
                    bottom: 5,
                    right: 5
                )
            )

        return AVMakeRect(
            aspectRatio: CGSize(
                width: 16,
                height: 9
            ),
            insideRect: insetRect
        )
    }

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

                let cellRectRespectingAspectRatio = computeParticipantCellSize(
                    fitting: CGRect(
                        origin: .zero,
                        size: contentSizeSplitIntoQuarters
                    ),
                    respecting: aspectRatio
                )

                let itemSize = NSCollectionLayoutSize(
                    widthDimension: .absolute(
                        cellRectRespectingAspectRatio.width
                    ),
                    heightDimension: .absolute(
                        cellRectRespectingAspectRatio.height
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
                        (cellRectRespectingAspectRatio.height)
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
