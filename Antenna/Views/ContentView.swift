import SwiftUI

enum SidebarItem: String, CaseIterable, Identifiable {
  case discover = "Discover"
  case search = "Search"

  var id: String { rawValue }

  var icon: String {
    switch self {
    case .discover: return "star"
    case .search: return "magnifyingglass"
    }
  }
}

struct ContentView: View {
  @Environment(PlayerViewModel.self) private var playerVM
  @State private var selectedTab: SidebarItem? = .discover
  var browseVM: BrowseViewModel

  var body: some View {
    NavigationSplitView {
      List(SidebarItem.allCases, id: \.self, selection: $selectedTab) { item in
        Label(item.rawValue, systemImage: item.icon)
      }
      .navigationSplitViewColumnWidth(min: 150, ideal: 180)
    } detail: {
      VStack(spacing: 0) {
        // Main content
        Group {
          switch selectedTab {
          case .discover:
            BrowseView(browseVM: browseVM)
          case .search:
            SearchView(browseVM: browseVM)
          case nil:
            Text("Select a tab")
              .foregroundStyle(.secondary)
          }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)

        // Now playing bar pinned to the bottom
        PlayerBarView()
      }
    }
  }
}
