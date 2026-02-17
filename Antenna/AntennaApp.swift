import SwiftUI

@main
struct AntennaApp: App {
  @State private var playerViewModel = PlayerViewModel()

  var body: some Scene {
    WindowGroup {
      ContentView()
        .environment(playerViewModel)
    }
    .defaultSize(width: 500, height: 600)
  }
}
