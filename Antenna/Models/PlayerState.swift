import Foundation

enum PlayerState: Equatable {
  case idle
  case loading
  case playing
  case paused
  case error(String)

  var isPlaying: Bool {
    self == .playing
  }

  var isLoading: Bool {
    self == .loading
  }

  var canPlay: Bool {
    switch self {
    case .idle, .paused, .error:
      return true
    case .loading, .playing:
      return false
    }
  }
}
