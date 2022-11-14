//
//  ParticipantVideoCell.swift
//

import UIKit

import MuxSpaces

class ParticipantVideoCell: UICollectionViewCell {

    // SpacesVideoView is recycled alongside collection view
    // cells.
    lazy var videoView = SpacesVideoView()

    lazy var videoContainerView = UIView()
    lazy var placeholderView = UILabel()
    lazy var nameIndicator = UILabel()

    var showsPlaceholder: Bool {
        videoView.track == nil
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

        if !contentView.subviews.contains(placeholderView) {
            placeholderView.textColor = .white

            placeholderView.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview(placeholderView)
            addConstraints([
                placeholderView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
                placeholderView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            ])
            placeholderView.backgroundColor = .black.withAlphaComponent(0.25)
        }

        if !contentView.subviews.contains(videoContainerView) {
            videoContainerView.translatesAutoresizingMaskIntoConstraints = false
            videoContainerView.clipsToBounds = true
            videoContainerView.layer.cornerRadius = 8.0

            contentView.insertSubview(videoContainerView, belowSubview: placeholderView)
            addConstraints([
                videoContainerView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
                videoContainerView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
                videoContainerView.widthAnchor.constraint(equalTo: contentView.widthAnchor),
                videoContainerView.heightAnchor.constraint(equalTo: contentView.heightAnchor),
            ])

            videoContainerView.addSubview(
                videoView
            )

            videoView.translatesAutoresizingMaskIntoConstraints = false

            addConstraints([
                videoView.leadingAnchor.constraint(
                    equalTo: videoContainerView.leadingAnchor
                ),
                videoView.trailingAnchor.constraint(
                    equalTo: videoContainerView.trailingAnchor
                ),
                videoView.topAnchor.constraint(
                    equalTo: videoContainerView.topAnchor
                ),
                videoView.bottomAnchor.constraint(
                    equalTo: videoContainerView.bottomAnchor
                )
            ])
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
                belowSubview: videoContainerView
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
        participantID: String,
        videoTrack: VideoTrack? = nil
    ) {
        videoView.track = videoTrack

        if videoTrack != nil {
            placeholderView.text = ""
            nameIndicator.text = participantID
            contentView.bringSubviewToFront(videoContainerView)
            contentView.bringSubviewToFront(nameIndicator)
        } else {
            placeholderView.text = participantID
            nameIndicator.text = ""
            contentView.bringSubviewToFront(placeholderView)
            contentView.sendSubviewToBack(videoContainerView)
            contentView.sendSubviewToBack(nameIndicator)
        }
    }
}
