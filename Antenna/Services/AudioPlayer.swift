import AVFoundation
import Combine
import MediaPlayer

@Observable
final class AudioPlayer {
  private(set) var state: PlayerState = .idle
  private(set) var currentStationName: String?

  private var player: AVPlayer?
  private var playerItem: AVPlayerItem?
  private var statusObservation: NSKeyValueObservation?
  private var timeControlObservation: NSKeyValueObservation?

  init() {
    setupRemoteCommands()
  }

  func play(url: URL, stationName: String) {
    stop()
    state = .loading
    currentStationName = stationName

    playerItem = AVPlayerItem(url: url)
    player = AVPlayer(playerItem: playerItem)

    observePlayer()
    player?.play()

    updateNowPlaying(stationName: stationName)
  }

  func pause() {
    player?.pause()
    state = .paused
    updatePlaybackState()
  }

  func resume() {
    player?.play()
    state = .playing
    updatePlaybackState()
  }

  func togglePlayPause() {
    switch state {
    case .playing:
      pause()
    case .paused:
      resume()
    default:
      break
    }
  }

  func stop() {
    statusObservation = nil
    timeControlObservation = nil
    player?.pause()
    player = nil
    playerItem = nil
    state = .idle
    currentStationName = nil
    clearNowPlaying()
  }

  // MARK: - Player Observation

  private func observePlayer() {
    statusObservation = playerItem?.observe(\.status, options: [.new]) { [weak self] item, _ in
      DispatchQueue.main.async {
        switch item.status {
        case .readyToPlay:
          break  // timeControlStatus will handle the .playing transition
        case .failed:
          let message = item.error?.localizedDescription ?? "Unknown error"
          self?.state = .error(message)
          self?.clearNowPlaying()
        default:
          break
        }
      }
    }

    timeControlObservation = player?.observe(\.timeControlStatus, options: [.new]) {
      [weak self] player, _ in
      DispatchQueue.main.async {
        switch player.timeControlStatus {
        case .playing:
          self?.state = .playing
          self?.updatePlaybackState()
        case .waitingToPlayAtSpecifiedRate:
          self?.state = .loading
        case .paused:
          if self?.state == .loading || self?.state == .idle {
            // Don't override loading or idle (stopped) state
          } else {
            self?.state = .paused
          }
          self?.updatePlaybackState()
        @unknown default:
          break
        }
      }
    }
  }

  // MARK: - Now Playing / Media Controls

  private func setupRemoteCommands() {
    let commandCenter = MPRemoteCommandCenter.shared()

    commandCenter.playCommand.isEnabled = true
    commandCenter.playCommand.addTarget { [weak self] _ in
      self?.resume()
      return .success
    }

    commandCenter.pauseCommand.isEnabled = true
    commandCenter.pauseCommand.addTarget { [weak self] _ in
      self?.pause()
      return .success
    }

    commandCenter.togglePlayPauseCommand.isEnabled = true
    commandCenter.togglePlayPauseCommand.addTarget { [weak self] _ in
      self?.togglePlayPause()
      return .success
    }

    commandCenter.stopCommand.isEnabled = true
    commandCenter.stopCommand.addTarget { [weak self] _ in
      self?.stop()
      return .success
    }
  }

  private func updateNowPlaying(stationName: String) {
    var info = [String: Any]()
    info[MPMediaItemPropertyTitle] = stationName
    info[MPNowPlayingInfoPropertyIsLiveStream] = true
    info[MPNowPlayingInfoPropertyMediaType] = MPNowPlayingInfoMediaType.audio.rawValue
    MPNowPlayingInfoCenter.default().nowPlayingInfo = info
    updatePlaybackState()
  }

  private func updatePlaybackState() {
    let center = MPNowPlayingInfoCenter.default()
    switch state {
    case .playing:
      center.playbackState = .playing
    case .paused:
      center.playbackState = .paused
    case .loading:
      center.playbackState = .playing
    case .idle:
      center.playbackState = .stopped
    case .error:
      center.playbackState = .stopped
    }
  }

  private func clearNowPlaying() {
    MPNowPlayingInfoCenter.default().nowPlayingInfo = nil
    MPNowPlayingInfoCenter.default().playbackState = .stopped
  }
}
