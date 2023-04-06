//
//  Created for SwiftUIExample.
//  
//  Copyright © 2023 Mux, Inc.
//  Licensed under the MIT License.
//

import Combine
import SwiftUI

import MuxSpaces

struct ContentView: View {
    @StateObject var model: SpaceModel = SpaceModel()

    var body: some View {
        let disableJoin = model.displayName == ""

        return NavigationView {
            VStack {
                VStack {
                    Text(model.frontFacingCamera ? "Front camera" : "Rear camera")
                    Toggle("Camera", isOn: $model.frontFacingCamera)
                        .labelsHidden()
                        .toggleStyle(SwitchToggleStyle(tint: .blue))
                }
                .frame(width: 280)
                .padding(.vertical)
                .overlay(
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(lineWidth: 2)
                )
                VStack {
                    Text("Name")
                    TextField("", text: $model.displayName)
                }
                .frame(width: 250)
                .padding()
                .overlay(
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(lineWidth: 2)
                )
                NavigationLink(destination: SpaceView(), label: {
                    Text("Join Space")
                        .bold()
                        .frame(width: 280, height: 50)
                        .background(disableJoin ? .gray : .blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }).disabled(disableJoin)
            }
        }
        .navigationViewStyle(.stack)
        .environmentObject(model)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct SpaceView: View {
    @EnvironmentObject var model: SpaceModel

    var body: some View {
        ZStack {
            if model.hasJoined {
                ParticipantsView()
            } else {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
            }
        }.toolbar {
            ControlsView()
        }.onAppear {
            model.join()
        }.onDisappear {
            model.leave()
        }
    }
}

struct ControlsView: View {
    @EnvironmentObject var model: SpaceModel

    var body: some View {
        Button {
            model.toggleCamera()
        } label: {
            Text(model.cameraOff ? "Camera On" : "Camera Off")
        }
        Button {
            model.toggleMicMute()
        } label: {
            Text(model.micMuted ? "Unmute" : "Mute")
        }
    }
}

struct ParticipantsView: View {
    @EnvironmentObject var model: SpaceModel

    let layout = [
        GridItem(.flexible()),
    ]

    var body: some View {
        ScrollView {
            LazyVGrid(columns: layout, spacing: 20) {
                ForEach($model.sortedParticipantItems, id: \.participant.id) { viewItem in
                    ParticipantView(
                        viewItem: viewItem
                    )
                }
            }
            .padding(.vertical, 10)
            .padding(.horizontal, 20.0)
        }
    }
}

struct ParticipantView: View {
    @Binding var viewItem: ParticipantVideoViewItem

    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        ZStack {
            if let videoTrack = viewItem.videoTrack, videoTrack.hasMedia, !videoTrack.isMuted {
                SpacesVideo(track: videoTrack)
            } else {
                Text(viewItem.participant.displayName)
                    .font(.system(size: 24))
                    .padding(.horizontal)
            }
            VStack {
                HStack {
                    Spacer()
                    if let audioTrack = viewItem.audioTrack, audioTrack.isMuted {
                        Image(systemName: "mic.slash")
                            .foregroundColor(.white)
                            .padding(9)
                            .background(
                                Color.black.opacity(0.4)
                            )
                            .clipShape(Circle())
                            .padding(8)
                    }
                }
                Spacer()

                HStack(alignment: .bottom) {
                    HStack(spacing: 12) {
                        Text(viewItem.participant.displayName)
                            .lineLimit(1)
                            .foregroundColor(.white)
                            .font(.system(size: 14))
                    }
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(
                        Color.black.opacity(0.7)
                    )
                    .cornerRadius(2)

                    Spacer()
                }
                .padding(4)
            }
        }
        .frame(minHeight: 200.0)
        .background(colorScheme == .dark ? .white : .black)
        .foregroundColor(colorScheme == .dark ? .black : .white)
        .cornerRadius(10)
        .overlay(
            viewItem.isActiveSpeaker ? RoundedRectangle(cornerRadius: 10)
                .stroke(Color.blue, lineWidth: 5) : nil
        )
    }
}

