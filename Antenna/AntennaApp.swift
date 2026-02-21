import SwiftUI

@main
struct AntennaApp: App {
  @Environment(\.openWindow) private var openWindow
  @State private var playerViewModel = PlayerViewModel()
  @State private var browseViewModel = BrowseViewModel()
  @State private var favoritesStore = FavoritesStore()
  @State private var selectedTab: SidebarItem? = .favorites
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
      CommandGroup(replacing: .appInfo) {
        Button("About Antenna") {
          openWindow(id: "about")
        }
      }
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

        Button("Favorites") {
          selectedTab = .favorites
        }
        .keyboardShortcut("1", modifiers: .command)

        Button("Discover") {
          selectedTab = .discover
        }
        .keyboardShortcut("2", modifiers: .command)

        Button("Search") {
          selectedTab = .search
        }
        .keyboardShortcut("3", modifiers: .command)
      }
    }

    Window("About Antenna", id: "about") {
      AboutView()
    }
    .windowResizability(.contentSize)
    .windowStyle(.titleBar)
    .defaultPosition(.center)
  }
}
