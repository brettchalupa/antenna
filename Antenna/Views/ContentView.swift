import SwiftUI

struct ContentView: View {
  @Environment(PlayerViewModel.self) private var playerVM
  @State private var streamURL = "https://wxpnhi.xpn.org/xpnhi-nopreroll"
  @State private var stationName = "WXPN 88.5"

  var body: some View {
    VStack(spacing: 0) {
      // Main content area
      VStack(spacing: 16) {
        Spacer()

        Image(systemName: "antenna.radiowaves.left.and.right")
          .font(.system(size: 48))
          .foregroundStyle(.secondary)

        Text("Antenna")
          .font(.largeTitle)
          .fontWeight(.bold)

        Text("Internet Radio Player")
          .font(.subheadline)
          .foregroundStyle(.secondary)

        Spacer()

        // Stream input section
        GroupBox("Play a Stream") {
          VStack(alignment: .leading, spacing: 12) {
            TextField("Station Name", text: $stationName)
              .textFieldStyle(.roundedBorder)

            TextField("Stream URL", text: $streamURL)
              .textFieldStyle(.roundedBorder)

            HStack {
              Spacer()
              Button {
                playerVM.playURL(streamURL, name: stationName)
              } label: {
                Label("Play", systemImage: "play.fill")
              }
              .buttonStyle(.borderedProminent)
              .disabled(streamURL.isEmpty)
            }
          }
          .padding(4)
        }
        .padding(.horizontal)

        Spacer()
      }
      .frame(maxWidth: .infinity, maxHeight: .infinity)

      // Now playing bar pinned to the bottom
      PlayerBarView()
    }
  }
}
