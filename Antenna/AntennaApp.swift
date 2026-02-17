import SwiftUI

@main
struct AntennaApp: App {
  @State private var playerViewModel = PlayerViewModel()
  @State private var browseViewModel = BrowseViewModel()
  @State private var favoritesStore = FavoritesStore()

  var body: some Scene {
    WindowGroup {
      ContentView(browseVM: browseViewModel)
        .environment(playerViewModel)
        .environment(favoritesStore)
    }
    .defaultSize(width: 700, height: 550)
  }
}
