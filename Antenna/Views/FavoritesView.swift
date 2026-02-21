import SwiftUI

struct FavoritesView: View {
  @Environment(PlayerViewModel.self) private var playerVM
  @Environment(FavoritesStore.self) private var favoritesStore
  @State private var showingAddStation = false

  var body: some View {
    Group {
      if favoritesStore.favorites.isEmpty {
        VStack(spacing: 12) {
          Image(systemName: "heart")
            .font(.largeTitle)
            .foregroundStyle(.secondary)
          Text("No favorites yet")
            .font(.headline)
            .foregroundStyle(.secondary)
          Text("Browse stations and tap the heart to save them here,\nor add a custom stream URL.")
            .font(.caption)
            .foregroundStyle(.tertiary)
            .multilineTextAlignment(.center)
          Button {
            showingAddStation = true
          } label: {
            Label("Add Custom Station", systemImage: "plus")
          }
          .buttonStyle(.borderedProminent)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
      } else {
        List {
          ForEach(favoritesStore.favorites) { station in
            StationRowView(
              station: station,
              isCurrentStation: playerVM.currentStation?.id == station.id,
              onPlay: { playerVM.play(station: station) }
            )
            .contextMenu {
              Button(role: .destructive) {
                favoritesStore.remove(station)
              } label: {
                Label("Remove from Favorites", systemImage: "heart.slash")
              }
            }
          }
          .onMove { source, destination in
            favoritesStore.move(from: source, to: destination)
          }
        }
      }
    }
    .toolbar {
      ToolbarItem {
        Button {
          showingAddStation = true
        } label: {
          Image(systemName: "plus")
        }
        .help("Add custom station")
      }
    }
    .sheet(isPresented: $showingAddStation) {
      AddStationView()
    }
  }
}
