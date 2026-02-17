import SwiftUI

@Observable
final class PlayerViewModel {
  let audioPlayer = AudioPlayer()
  private(set) var currentStation: Station?

  var state: PlayerState {
    audioPlayer.state
  }

  var isPlaying: Bool {
    state.isPlaying
  }

  var isLoading: Bool {
    state.isLoading
  }

  var volume: Float {
    get { audioPlayer.volume }
    set { audioPlayer.volume = newValue }
  }

  func play(station: Station) {
    guard let url = station.streamURL else {
      return
    }
    currentStation = station
    audioPlayer.play(url: url, stationName: station.name)
  }

  func playURL(_ urlString: String, name: String? = nil) {
    let stationName = name ?? urlString
    let station = Station.custom(name: stationName, url: urlString)
    play(station: station)
  }

  func togglePlayPause() {
    audioPlayer.togglePlayPause()
  }

  func stop() {
    audioPlayer.stop()
    currentStation = nil
  }
}
