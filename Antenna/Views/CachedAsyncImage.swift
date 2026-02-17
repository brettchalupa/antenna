import SwiftUI

struct CachedAsyncImage: View {
  let url: URL?
  @State private var image: NSImage?
  @State private var isLoading = false

  var body: some View {
    Group {
      if let image {
        Image(nsImage: image)
          .resizable()
          .aspectRatio(contentMode: .fit)
      } else {
        Image(systemName: "radio")
          .foregroundStyle(.secondary)
      }
    }
    .task(id: url) {
      guard let url, !isLoading else { return }
      isLoading = true
      image = await ImageCache.shared.image(for: url)
      isLoading = false
    }
  }
}
