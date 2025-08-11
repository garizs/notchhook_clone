import SwiftUI

struct SettingsView: View {
    var body: some View {
        Form {
            Section(header: Text("Appearance")) {
                Text("The centered pill auto-positions under the notch.")
            }
            Section(header: Text("Controls")) {
                Text("Use media buttons or menu bar. Click the progress bar to seek (if supported).")
            }
            Section(header: Text("Privacy / Permissions")) {
                Text("Chrome and many players expose metadata via Media Session → MediaRemote. No audio is recorded.")
            }
        }
        .padding()
        .frame(width: 520)
    }
}
