import Foundation

@MainActor
@Observable
final class FavoritesStore {
  private(set) var favorites: [Station] = []

  private let fileURL: URL

  init() {
    let appSupport = FileManager.default.urls(
      for: .applicationSupportDirectory, in: .userDomainMask
    )
    .first!
    let antennaDir = appSupport.appendingPathComponent("Antenna", isDirectory: true)

    // Ensure directory exists
    try? FileManager.default.createDirectory(at: antennaDir, withIntermediateDirectories: true)

    fileURL = antennaDir.appendingPathComponent("favorites.json")
    load()
  }

  func add(_ station: Station) {
    guard !isFavorite(station) else { return }
    favorites.append(station)
    save()
  }

  func remove(_ station: Station) {
    favorites.removeAll { $0.stationuuid == station.stationuuid }
    save()
  }

  func move(from source: IndexSet, to destination: Int) {
    favorites.move(fromOffsets: source, toOffset: destination)
    save()
  }

  func toggle(_ station: Station) {
    if isFavorite(station) {
      remove(station)
    } else {
      add(station)
    }
  }

  func isFavorite(_ station: Station) -> Bool {
    favorites.contains { $0.stationuuid == station.stationuuid }
  }

  func isFavorite(id: String) -> Bool {
    favorites.contains { $0.stationuuid == id }
  }

  // MARK: - Persistence

  private func save() {
    do {
      let data = try JSONEncoder().encode(favorites)
      try data.write(to: fileURL, options: .atomic)
    } catch {
      print("Failed to save favorites: \(error)")
    }
  }

  private func load() {
    guard FileManager.default.fileExists(atPath: fileURL.path) else { return }
    do {
      let data = try Data(contentsOf: fileURL)
      favorites = try JSONDecoder().decode([Station].self, from: data)
    } catch {
      print("Failed to load favorites: \(error)")
    }
  }
}
