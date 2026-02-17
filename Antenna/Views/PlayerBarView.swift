import SwiftUI

struct PlayerBarView: View {
  @Environment(PlayerViewModel.self) private var playerVM

  var body: some View {
    @Bindable var player = playerVM
    HStack(spacing: 12) {
      VStack(alignment: .leading, spacing: 2) {
        if playerVM.currentStation == nil {
          Text("Select a station to start listening")
            .font(.headline)
            .foregroundStyle(.tertiary)
            .lineLimit(1)
        } else {
          Text(playerVM.currentStation?.name ?? "Untitled Station")
            .font(.headline)
            .lineLimit(1)

          statusText
            .font(.caption)
            .foregroundStyle(.secondary)
        }
      }

      Spacer()

      // Volume slider
      HStack(spacing: 4) {
        Image(systemName: volumeIcon)
          .font(.caption)
          .foregroundStyle(.secondary)
          .frame(width: 14)
        Slider(value: $player.volume, in: 0...1)
          .frame(width: 80)
        Image(systemName: "speaker.wave.3.fill")
          .font(.caption)
          .foregroundStyle(.secondary)
          .frame(width: 14)
      }

      if playerVM.currentStation != nil {
        HStack(spacing: 8) {
          Button {
            playerVM.togglePlayPause()
          } label: {
            Image(systemName: playPauseIcon)
              .font(.title2)
              .frame(width: 32, height: 32)
          }
          .buttonStyle(.borderless)
          .disabled(playerVM.isLoading)

          Button {
            playerVM.stop()
          } label: {
            Image(systemName: "stop.fill")
              .font(.title3)
              .frame(width: 32, height: 32)
          }
          .buttonStyle(.borderless)
        }
      }
    }
    .padding(.horizontal, 16)
    .padding(.vertical, 10)
    .background(.bar)
    .overlay(alignment: .top) {
      Divider()
    }
  }

  private var volumeIcon: String {
    if playerVM.volume == 0 {
      return "speaker.slash.fill"
    } else if playerVM.volume < 0.5 {
      return "speaker.wave.1.fill"
    } else {
      return "speaker.wave.2.fill"
    }
  }

  private var playPauseIcon: String {
    switch playerVM.state {
    case .playing:
      return "pause.fill"
    case .loading:
      return "ellipsis"
    default:
      return "play.fill"
    }
  }

  @ViewBuilder
  private var statusText: some View {
    switch playerVM.state {
    case .playing:
      Text("Playing")
    case .loading:
      HStack(spacing: 4) {
        ProgressView()
          .controlSize(.small)
        Text("Connecting...")
      }
    case .paused:
      Text("Paused")
    case .error(let message):
      Text(message)
        .foregroundStyle(.red)
    case .idle:
      EmptyView()
    }
  }
}
