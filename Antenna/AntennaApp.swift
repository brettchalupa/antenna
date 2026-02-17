import SwiftUI

@main
struct AntennaApp: App {
  @State private var playerViewModel = PlayerViewModel()
  @State private var browseViewModel = BrowseViewModel()

  var body: some Scene {
    WindowGroup {
      ContentView(browseVM: browseViewModel)
        .environment(playerViewModel)
    }
    .defaultSize(width: 700, height: 550)
  }
}
