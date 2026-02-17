import SwiftUI

struct BrowseView: View {
  @Environment(PlayerViewModel.self) private var playerVM
  var browseVM: BrowseViewModel

  var body: some View {
    Group {
      if browseVM.isLoadingDiscover && browseVM.topVoted.isEmpty {
        VStack(spacing: 12) {
          ProgressView()
          Text("Loading stations...")
            .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
      } else if let error = browseVM.discoverError, browseVM.topVoted.isEmpty {
        VStack(spacing: 12) {
          Image(systemName: "wifi.exclamationmark")
            .font(.largeTitle)
            .foregroundStyle(.secondary)
          Text(error)
            .foregroundStyle(.secondary)
          Button("Retry") {
            Task { await browseVM.loadDiscover() }
          }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
      } else {
        stationList
      }
    }
    .task {
      await browseVM.loadDiscover()
    }
  }

  private var stationList: some View {
    List {
      if !browseVM.topVoted.isEmpty {
        Section("Popular") {
          ForEach(browseVM.topVoted) { station in
            StationRowView(
              station: station,
              isCurrentStation: playerVM.currentStation?.id == station.id,
              onPlay: { playStation(station) }
            )
          }
        }
      }

      if !browseVM.topClicked.isEmpty {
        Section("Trending") {
          ForEach(browseVM.topClicked) { station in
            StationRowView(
              station: station,
              isCurrentStation: playerVM.currentStation?.id == station.id,
              onPlay: { playStation(station) }
            )
          }
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
