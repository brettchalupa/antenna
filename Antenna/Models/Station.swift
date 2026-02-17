import Foundation

struct Station: Codable, Identifiable, Hashable {
  let stationuuid: String
  let name: String
  let url: String
  let urlResolved: String
  let homepage: String?
  let favicon: String?
  let countrycode: String
  let state: String?
  let tags: String
  let codec: String?
  let bitrate: Int
  let votes: Int
  let clickcount: Int
  let lastcheckok: Int

  var id: String { stationuuid }

  var streamURL: URL? {
    URL(string: urlResolved.isEmpty ? url : urlResolved)
  }

  var tagList: [String] {
    tags.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }
  }

  var faviconURL: URL? {
    guard let favicon, !favicon.isEmpty else { return nil }
    return URL(string: favicon)
  }

  var isOnline: Bool {
    lastcheckok == 1
  }

  enum CodingKeys: String, CodingKey {
    case stationuuid, name, url, homepage, favicon, countrycode, state, tags, codec, bitrate, votes,
      clickcount, lastcheckok
    case urlResolved = "url_resolved"
  }

  /// Create a custom station from a user-provided URL
  static func custom(name: String, url: String) -> Station {
    Station(
      stationuuid: UUID().uuidString,
      name: name,
      url: url,
      urlResolved: url,
      homepage: nil,
      favicon: nil,
      countrycode: "",
      state: nil,
      tags: "",
      codec: nil,
      bitrate: 0,
      votes: 0,
      clickcount: 0,
      lastcheckok: 1
    )
  }
}
