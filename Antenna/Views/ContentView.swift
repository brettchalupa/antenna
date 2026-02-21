import SwiftUI

enum SidebarItem: String, CaseIterable, Identifiable {
  case favorites = "Favorites"
  case discover = "Discover"
  case search = "Search"

  var id: String { rawValue }

  var icon: String {
    switch self {
    case .favorites: return "heart"
    case .discover: return "globe"
    case .search: return "magnifyingglass"
    }
  }
}

struct ContentView: View {
  @Environment(PlayerViewModel.self) private var playerVM
  @Environment(\.openWindow) private var openWindow
  var browseVM: BrowseViewModel
  @Binding var selectedTab: SidebarItem?
  @Binding var searchFocusTrigger: Int

  var body: some View {
    NavigationSplitView {
      List(SidebarItem.allCases, id: \.self, selection: $selectedTab) { item in
        Label(item.rawValue, systemImage: item.icon)
      }
      .safeAreaInset(edge: .bottom) {
        Button {
          openWindow(id: "about")
        } label: {
          Label("About", systemImage: "info.circle")
            .font(.caption)
            .foregroundColor(.secondary)
        }
        .buttonStyle(.plain)
        .padding(.vertical, 8)
        .frame(maxWidth: .infinity)
      }
      .navigationSplitViewColumnWidth(min: 150, ideal: 180)
    } detail: {
      VStack(spacing: 0) {
        Group {
          switch selectedTab {
          case .discover:
            BrowseView(browseVM: browseVM)
          case .search:
            SearchView(browseVM: browseVM, focusTrigger: $searchFocusTrigger)
          case .favorites:
            FavoritesView()
          case nil:
            Text("Select a tab")
              .foregroundStyle(.secondary)
          }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)

        PlayerBarView()
      }
    }
  }
}
