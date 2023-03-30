//
//  SpacesVideo.swift
//

import SwiftUI

import MuxSpaces

// MARK: - SpacesVideoView SwiftUI

/// A SwiftUI convenience wrapper that you use to integrate
/// ``SpacesVideoView`` into your SwiftUI view hierarchy.
///
public struct SpacesVideo: UIViewRepresentable {

    /// Corresponds to ``SpacesVideoView.track``
    ///
    public var track: VideoTrack?

    public init(
        track: VideoTrack? = nil
    ) {
        self.track = track
    }

    /// The type of view to present.
    ///
    public typealias UIViewType = SpacesVideoView

    /// Creates a ``SpacesVideoView`` and configures its
    /// initial state.
    ///
    public func makeUIView(context: Context) -> SpacesVideoView {
        return SpacesVideoView(
            track: track
        )
    }

    /// Updates the state of ``SpacesVideoView`` with new
    /// information from SwiftUI.
    ///
    public func updateUIView(_ uiView: SpacesVideoView, context: Context) {
        if (track?.id ?? "") != (uiView.track?.id ?? "") {
            uiView.track = track
        }
    }
}

@available(iOS 16, *)
/// Convenience constructor for a `UIHostingConfiguration`
/// that displays a video from a participant in a space.
///
/// - Parameters:
///   - space: space that the participant has joined.
///   - track: track that is the source of the participants
///   video.
///   - background: The background contents for the hosting
///   configuration's enclosing cell.
/// - Returns: Returns a UIHostingConfiguration enabling ``SpacesVideo``
/// to be shown inside a `UICollectionViewCell`.
///
public func makeHostingConfiguration<Background: View>(
    track: VideoTrack? = nil,
    background: Background
) -> UIHostingConfiguration<SpacesVideo, Background> {
    return UIHostingConfiguration {
        SpacesVideo(
            track: track
        )
    }.background {
        background
    }
}
