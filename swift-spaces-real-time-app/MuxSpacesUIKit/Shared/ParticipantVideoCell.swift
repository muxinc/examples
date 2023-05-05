//
//  Created for MuxSpacesUIKit.
//
//  Copyright © 2022 Mux, Inc.
//  Licensed under the MIT License.
//

import UIKit

import MuxSpaces

class ParticipantVideoCell: UICollectionViewCell {

    // SpacesVideoView gets recycled with collection view cells.
    lazy var videoView = SpacesVideoView()

    lazy var placeholderView = UILabel()
    lazy var nameIndicator = UILabel()

    lazy var muteIndicator = UIImageView()

    var showsPlaceholder: Bool {
        videoView.track == nil || videoView.track?.isMuted == true
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        // clear participant data when
        // collection view cell is reused
        placeholderView.text = ""
        nameIndicator.text = ""

        // clear the video view track when
        // collection view cell is reused
        videoView.track = nil
    }

    func setup() {
        backgroundView?.layer.cornerRadius = 8.0
        contentView.layer.cornerRadius = 8.0
        contentView.clipsToBounds = true
        contentView.backgroundColor = .black

        if !contentView.subviews.contains(placeholderView) {
            placeholderView.textColor = .white

            placeholderView
                .translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview(
                placeholderView
            )
            addConstraints([
                placeholderView.centerXAnchor.constraint(
                    equalTo: contentView.centerXAnchor
                ),
                placeholderView.centerYAnchor.constraint(
                    equalTo: contentView.centerYAnchor
                ),
            ])
            placeholderView.backgroundColor = .black
                .withAlphaComponent(
                    0.25
                )
        }

        if !contentView.subviews.contains(videoView) {
            videoView.translatesAutoresizingMaskIntoConstraints = false
            videoView.clipsToBounds = true
            videoView.layer.cornerRadius = 8.0

            contentView.insertSubview(
                videoView,
                belowSubview: placeholderView
            )
            addConstraints([
                videoView.centerXAnchor.constraint(
                    equalTo: contentView.centerXAnchor
                ),
                videoView.centerYAnchor.constraint(
                    equalTo: contentView.centerYAnchor
                ),
                videoView.widthAnchor.constraint(
                    equalTo: contentView.widthAnchor
                ),
                videoView.heightAnchor.constraint(
                    equalTo: contentView.heightAnchor
                ),
            ])

            videoView.translatesAutoresizingMaskIntoConstraints = false
        }

        if !contentView.subviews.contains(nameIndicator) {
            nameIndicator.backgroundColor = .black.withAlphaComponent(0.25)
            nameIndicator.textColor = .white
            nameIndicator.textAlignment = .center
            nameIndicator.lineBreakMode = .byClipping
            nameIndicator.font = UIFont.preferredFont(
                forTextStyle: .subheadline
            ).withSize(14.0)

            nameIndicator.translatesAutoresizingMaskIntoConstraints = false
            contentView.insertSubview(
                nameIndicator,
                belowSubview: videoView
            )
            addConstraints([
                nameIndicator.widthAnchor.constraint(
                    equalTo: contentView.widthAnchor
                ),
                nameIndicator.heightAnchor.constraint(
                    equalToConstant: 32.0
                ),
                nameIndicator.centerXAnchor.constraint(
                    equalTo: contentView.centerXAnchor
                ),
                nameIndicator.bottomAnchor.constraint(
                    equalTo: contentView.bottomAnchor
                )
            ])
        }
    }

    func update(
        displayName: String,
        videoTrack: VideoTrack? = nil,
        audioTrack: AudioTrack? = nil
    ) {
        if let videoTrack {
            videoView.track = videoTrack
        }

        if let audioTrack {
            muteIndicator.isHidden = !audioTrack.isMuted
        }

        if showsPlaceholder {
            /// Show black background with participant ID
            /// displayed inside a centered label
            placeholderView.text = displayName
            nameIndicator.text = ""
            contentView.bringSubviewToFront(placeholderView)
            contentView.sendSubviewToBack(videoView)
            contentView.sendSubviewToBack(nameIndicator)
        } else {
            /// Show SpacesVideoView with participant ID on
            /// a semi-translucent bar overlay
            placeholderView.text = ""
            nameIndicator.text = displayName
            contentView.bringSubviewToFront(videoView)
            contentView.bringSubviewToFront(nameIndicator)
        }
    }
}
