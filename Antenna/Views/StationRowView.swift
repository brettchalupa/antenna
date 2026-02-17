import SwiftUI

struct StationRowView: View {
  @Environment(FavoritesStore.self) private var favoritesStore
  let station: Station
  let isCurrentStation: Bool
  let onPlay: () -> Void

  var body: some View {
    HStack(spacing: 10) {
      // Favicon
      CachedAsyncImage(url: station.faviconURL)
        .frame(width: 32, height: 32)
        .clipShape(RoundedRectangle(cornerRadius: 6))

      // Station info
      VStack(alignment: .leading, spacing: 2) {
        Text(station.name)
          .font(.body)
          .fontWeight(isCurrentStation ? .semibold : .regular)
          .lineLimit(1)

        HStack(spacing: 6) {
          if !station.countrycode.isEmpty {
            Text(flagEmoji(for: station.countrycode))
              .font(.caption)
          }

          if !station.tags.isEmpty {
            Text(station.tagList.prefix(3).joined(separator: ", "))
              .font(.caption)
              .foregroundStyle(.secondary)
              .lineLimit(1)
          }

          if station.bitrate > 0 {
            Text("\(station.bitrate)kbps")
              .font(.caption2)
              .padding(.horizontal, 4)
              .padding(.vertical, 1)
              .background(.quaternary)
              .clipShape(RoundedRectangle(cornerRadius: 3))
          }
        }
      }

      Spacer()

      // Favorite toggle
      Button {
        favoritesStore.toggle(station)
      } label: {
        Image(systemName: favoritesStore.isFavorite(station) ? "heart.fill" : "heart")
          .font(.body)
          .frame(width: 28, height: 28)
      }
      .buttonStyle(.borderless)
      .foregroundColor(favoritesStore.isFavorite(station) ? .red : .secondary)

      // Play button
      Button {
        onPlay()
      } label: {
        Image(systemName: isCurrentStation ? "speaker.wave.2.fill" : "play.fill")
          .font(.body)
          .frame(width: 28, height: 28)
      }
      .buttonStyle(.borderless)
      .foregroundColor(isCurrentStation ? .accentColor : .primary)
    }
    .padding(.vertical, 4)
    .contentShape(Rectangle())
  }
}

private func flagEmoji(for countryCode: String) -> String {
  let base: UInt32 = 127_397
  return countryCode.uppercased().unicodeScalars.compactMap { UnicodeScalar(base + $0.value) }
    .map { String($0) }
    .joined()
}
