import Foundation

struct RadioBrowserAPI {
  static let shared = RadioBrowserAPI()

  private let session: URLSession
  private let userAgent = "Antenna/0.1"

  private init() {
    let config = URLSessionConfiguration.default
    config.httpAdditionalHeaders = ["User-Agent": userAgent]
    config.timeoutIntervalForRequest = 15
    session = URLSession(configuration: config)
  }

  // MARK: - Server Discovery

  /// Resolve a random API server via DNS lookup of all.api.radio-browser.info
  private func resolveServerBase() async throws -> URL {
    // Resolve DNS to get available servers
    let host = CFHostCreateWithName(nil, "all.api.radio-browser.info" as CFString)
      .takeRetainedValue()
    var resolved = DarwinBoolean(false)
    CFHostStartInfoResolution(host, .addresses, nil)
    guard let addresses = CFHostGetAddressing(host, &resolved)?.takeUnretainedValue() as? [Data],
      !addresses.isEmpty
    else {
      // Fallback to a known server
      return URL(string: "https://de2.api.radio-browser.info")!
    }

    // Pick a random address and resolve its hostname
    let address = addresses.randomElement()!
    var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
    let result = address.withUnsafeBytes { ptr -> Int32 in
      let sockaddr = ptr.baseAddress!.assumingMemoryBound(to: sockaddr.self)
      return getnameinfo(
        sockaddr, socklen_t(address.count),
        &hostname, socklen_t(hostname.count),
        nil, 0, NI_NAMEREQD)
    }

    if result == 0 {
      let name = String(cString: hostname)
      return URL(string: "https://\(name)")!
    }

    return URL(string: "https://de2.api.radio-browser.info")!
  }

  private func baseURL() async throws -> URL {
    try await resolveServerBase()
  }

  // MARK: - Station Endpoints

  func searchStations(
    name: String = "",
    tag: String = "",
    country: String = "",
    countryCode: String = "",
    limit: Int = 50,
    offset: Int = 0
  ) async throws -> [Station] {
    var params: [(String, String)] = [
      ("limit", String(limit)),
      ("offset", String(offset)),
      ("hidebroken", "true"),
      ("order", "votes"),
      ("reverse", "true"),
    ]
    if !name.isEmpty { params.append(("name", name)) }
    if !tag.isEmpty { params.append(("tag", tag)) }
    if !country.isEmpty { params.append(("country", country)) }
    if !countryCode.isEmpty { params.append(("countrycode", countryCode)) }

    return try await request(path: "/json/stations/search", params: params)
  }

  func getTopVoted(limit: Int = 50) async throws -> [Station] {
    try await request(
      path: "/json/stations/topvote/\(limit)",
      params: [("hidebroken", "true")])
  }

  func getTopClicked(limit: Int = 50) async throws -> [Station] {
    try await request(
      path: "/json/stations/topclick/\(limit)",
      params: [("hidebroken", "true")])
  }

  func getCountries() async throws -> [Country] {
    try await request(
      path: "/json/countries",
      params: [
        ("order", "stationcount"),
        ("reverse", "true"),
        ("hidebroken", "true"),
      ])
  }

  func getTags(limit: Int = 100) async throws -> [Tag] {
    try await request(
      path: "/json/tags",
      params: [
        ("order", "stationcount"),
        ("reverse", "true"),
        ("hidebroken", "true"),
        ("limit", String(limit)),
      ])
  }

  /// Report a station click (call when user starts playing a station from the directory)
  func clickStation(uuid: String) async throws {
    let base = try await baseURL()
    let url = base.appendingPathComponent("/json/url/\(uuid)")
    _ = try await session.data(from: url)
  }

  // MARK: - Generic Request

  private func request<T: Decodable>(path: String, params: [(String, String)]) async throws -> [T] {
    let base = try await baseURL()
    var components = URLComponents(
      url: base.appendingPathComponent(path), resolvingAgainstBaseURL: false)!
    components.queryItems = params.map { URLQueryItem(name: $0.0, value: $0.1) }

    guard let url = components.url else {
      throw APIError.invalidURL
    }

    let (data, response) = try await session.data(from: url)

    guard let httpResponse = response as? HTTPURLResponse,
      (200...299).contains(httpResponse.statusCode)
    else {
      throw APIError.serverError
    }

    let decoder = JSONDecoder()
    return try decoder.decode([T].self, from: data)
  }
}

// MARK: - Supporting Types

struct Country: Codable, Identifiable {
  let name: String
  let isoCode: String
  let stationcount: Int

  var id: String { isoCode }

  enum CodingKeys: String, CodingKey {
    case name
    case isoCode = "iso_3166_1"
    case stationcount
  }
}

struct Tag: Codable, Identifiable {
  let name: String
  let stationcount: Int

  var id: String { name }
}

enum APIError: LocalizedError {
  case invalidURL
  case serverError

  var errorDescription: String? {
    switch self {
    case .invalidURL: return "Invalid API URL"
    case .serverError: return "Server returned an error"
    }
  }
}
