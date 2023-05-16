import SwiftUI

struct ControlsView: View {
    @EnvironmentObject var model: SpaceModel

    var body: some View {
        Button {
            model.flipCamera()
        } label: {
            Text(model.frontFacingCamera ? "Rear Camera" : "Front Camera")
        }
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

struct ControlsView_Previews: PreviewProvider {
    static let model = SpaceModel()

    static var previews: some View {
        NavigationView {
            ZStack {}.toolbar {
                ControlsView()
            }
        }
        .navigationViewStyle(.stack)
        .environmentObject(model)
    }
}
