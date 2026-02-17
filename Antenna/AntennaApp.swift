import SwiftUI

@main
struct AntennaApp: App {
  @State private var playerViewModel = PlayerViewModel()
  @State private var browseViewModel = BrowseViewModel()
  @State private var favoritesStore = FavoritesStore()
  @State private var selectedTab: SidebarItem? = .discover
  @State private var searchFocusTrigger = 0

  var body: some Scene {
    WindowGroup {
      ContentView(
        browseVM: browseViewModel,
        selectedTab: $selectedTab,
        searchFocusTrigger: $searchFocusTrigger
      )
      .environment(playerViewModel)
      .environment(favoritesStore)
    }
    .defaultSize(width: 700, height: 550)
    .commands {
      CommandMenu("Playback") {
        Button(playerViewModel.isPlaying ? "Pause" : "Play") {
          playerViewModel.togglePlayPause()
        }
        .keyboardShortcut("p", modifiers: .command)
        .disabled(playerViewModel.state == .idle)

        Button("Stop") {
          playerViewModel.stop()
        }
        .keyboardShortcut(".", modifiers: .command)
        .disabled(playerViewModel.state == .idle)
      }

      CommandMenu("Navigation") {
        Button("Find Station") {
          selectedTab = .search
          searchFocusTrigger += 1
        }
        .keyboardShortcut("f", modifiers: .command)

        Divider()

        Button("Discover") {
          selectedTab = .discover
        }
        .keyboardShortcut("1", modifiers: .command)

        Button("Search") {
          selectedTab = .search
        }
        .keyboardShortcut("2", modifiers: .command)

        Button("Favorites") {
          selectedTab = .favorites
        }
        .keyboardShortcut("3", modifiers: .command)
      }
    }
  }
}
