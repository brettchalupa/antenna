import AppKit
import CryptoKit
import Foundation

actor ImageCache {
  static let shared = ImageCache()

  private let cacheDir: URL
  private var memoryCache: [String: NSImage] = [:]

  private init() {
    let caches = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
    cacheDir = caches.appendingPathComponent("Antenna/favicons", isDirectory: true)
    try? FileManager.default.createDirectory(at: cacheDir, withIntermediateDirectories: true)
  }

  func image(for url: URL) async -> NSImage? {
    let key = cacheKey(for: url)

    // Memory cache
    if let cached = memoryCache[key] {
      return cached
    }

    // Disk cache
    let filePath = cacheDir.appendingPathComponent(key)
    if let data = try? Data(contentsOf: filePath),
      let image = NSImage(data: data)
    {
      memoryCache[key] = image
      return image
    }

    // Network fetch
    do {
      let (data, response) = try await URLSession.shared.data(from: url)
      guard let httpResponse = response as? HTTPURLResponse,
        (200...299).contains(httpResponse.statusCode),
        let image = NSImage(data: data)
      else {
        return nil
      }

      // Write to disk and memory
      try? data.write(to: filePath, options: .atomic)
      memoryCache[key] = image
      return image
    } catch {
      return nil
    }
  }

  private func cacheKey(for url: URL) -> String {
    let hash = SHA256.hash(data: Data(url.absoluteString.utf8))
    return hash.map { String(format: "%02x", $0) }.joined()
  }
}
