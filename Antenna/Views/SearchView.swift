import SwiftUI

struct SearchView: View {
  @Environment(PlayerViewModel.self) private var playerVM
  @Bindable var browseVM: BrowseViewModel

  var body: some View {
    VStack(spacing: 0) {
      // Search bar
      HStack(spacing: 8) {
        Image(systemName: "magnifyingglass")
          .foregroundStyle(.secondary)
        TextField("Search stations...", text: $browseVM.searchText)
          .textFieldStyle(.plain)
          .onSubmit { Task { await browseVM.search() } }

        if browseVM.hasSearchQuery {
          Button {
            browseVM.clearSearch()
          } label: {
            Image(systemName: "xmark.circle.fill")
              .foregroundStyle(.secondary)
          }
          .buttonStyle(.borderless)
        }
      }
      .padding(10)
      .background(.bar)

      Divider()

      // Results
      if browseVM.isLoadingSearch {
        VStack(spacing: 12) {
          ProgressView()
          Text("Searching...")
            .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
      } else if let error = browseVM.searchError {
        VStack(spacing: 12) {
          Image(systemName: "exclamationmark.triangle")
            .font(.largeTitle)
            .foregroundStyle(.secondary)
          Text(error)
            .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
      } else if browseVM.searchResults.isEmpty && browseVM.hasSearchQuery {
        VStack(spacing: 12) {
          Image(systemName: "magnifyingglass")
            .font(.largeTitle)
            .foregroundStyle(.secondary)
          Text("No stations found")
            .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
      } else if browseVM.searchResults.isEmpty {
        VStack(spacing: 12) {
          Image(systemName: "antenna.radiowaves.left.and.right")
            .font(.largeTitle)
            .foregroundStyle(.secondary)
          Text("Search over 50,000 stations")
            .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
      } else {
        List(browseVM.searchResults) { station in
          StationRowView(
            station: station,
            isCurrentStation: playerVM.currentStation?.id == station.id,
            onPlay: { playStation(station) }
          )
        }
      }
    }
  }

  private func playStation(_ station: Station) {
    playerVM.play(station: station)
    Task {
      try? await RadioBrowserAPI.shared.clickStation(uuid: station.stationuuid)
    }
  }
}
