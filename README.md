# Antenna

A free, open-source internet radio player for macOS. Browse, search, and listen
to 50,000+ stations from the [Radio Browser](https://www.radio-browser.info/)
directory. Built with Swift 6 and SwiftUI.

![macOS 14+](https://img.shields.io/badge/macOS-14%2B-blue)
![Swift 6](https://img.shields.io/badge/Swift-6-orange)
![License: Unlicense](https://img.shields.io/badge/license-Unlicense-blue)

## Download

Download the latest release from [GitHub Releases](https://github.com/brettchalupa/antenna/releases/latest). Unzip and drag `Antenna.app` to your Applications folder.

Requires macOS 14 (Sonoma) or later.

## Features

- **Discover** — Browse popular and trending stations worldwide
- **Search** — Find stations by name across 50,000+ entries
- **Favorites** — Save stations for quick access, persisted across launches
- **Custom Stations** — Add any stream URL (MP3, AAC, HLS)
- **Media Controls** — Play/pause from media keys, headphones, and macOS Control
  Center
- **Now Playing** — Station info in macOS Control Center and Touch Bar
- **Volume Control** — Adjustable volume slider, persisted across launches
- **Keyboard Shortcuts** — Cmd+P play/pause, Cmd+. stop, Cmd+F find, Cmd+1/2/3
  navigate

## Building from Source

Requirements: macOS 14+, Xcode 16+, [XcodeGen](https://github.com/yonaskolb/XcodeGen), [SwiftLint](https://github.com/realm/SwiftLint), [just](https://github.com/casey/just)

```bash
# Install prerequisites
brew install just xcodegen swiftlint

# Clone the repo
git clone https://github.com/brettchalupa/antenna.git
cd antenna

# Generate the Xcode project
just generate

# Build and run
just run
```

## Development

All development tasks use [`just`](https://github.com/casey/just):

```bash
just ok          # Format + lint + build (run before every commit)
just run         # Build and launch the app
just generate    # Regenerate .xcodeproj from project.yml
just rebuild     # Regenerate + build
just format      # Format Swift sources
just lint        # Run SwiftLint
just lint-fix    # Auto-fix lint issues
just test        # Run tests
just clean       # Remove build artifacts
just open        # Open project in Xcode
```

`just ok` is the gate check — it runs the formatter, linter, and compiler.
Everything must pass with zero violations.

## Architecture

MVVM with SwiftUI and Swift 6 strict concurrency.

```
RadioBrowserAPI  -->  BrowseViewModel  -->  BrowseView / SearchView
                                                |
                                           user plays station
                                                |
FavoritesStore  <--  PlayerViewModel  -->  AudioPlayer
                          |                     |
                     PlayerBarView      MPNowPlayingInfoCenter
                                        MPRemoteCommandCenter
```

- **Models** — `Station` (Codable, matches Radio Browser API), `PlayerState`
  enum
- **Services** — `AudioPlayer` (AVPlayer + media controls), `RadioBrowserAPI`
  (async HTTP client with DNS server discovery), `FavoritesStore` (JSON file
  persistence), `ImageCache` (actor-based favicon cache)
- **ViewModels** — `PlayerViewModel` (playback bridge), `BrowseViewModel`
  (search + discovery)
- **Views** — `ContentView` (sidebar navigation), tab views, `PlayerBarView`
  (bottom bar with controls + volume), `StationRowView` (station list item with
  favicon)

## App Icon

The app icon is generated programmatically:

```bash
swift scripts/generate_icon.swift
```

This renders the [FontAwesome radio icon](https://fontawesome.com/icons/radio)
(MIT licensed) on a gradient background into all required sizes in the asset
catalog.

## Tech Stack

| Component      | Technology                                                              |
| -------------- | ----------------------------------------------------------------------- |
| UI             | SwiftUI                                                                 |
| Audio          | AVPlayer (AVFoundation)                                                 |
| Media Controls | MediaPlayer (MPRemoteCommandCenter, MPNowPlayingInfoCenter)             |
| Station Data   | [Radio Browser API](https://api.radio-browser.info/) (free, no API key) |
| Persistence    | JSON file + UserDefaults                                                |
| Project Gen    | XcodeGen                                                                |
| Linting        | SwiftLint                                                               |
| Formatting     | swift-format                                                            |
| Task Runner    | just                                                                    |

## Contributing

Contributions are welcome! See [CONTRIBUTING.md](CONTRIBUTING.md) for setup
instructions and guidelines.

## Support

If you enjoy Antenna, consider [buying me a coffee](https://buymeacoffee.com/brettchalupa).

## License

This project is released into the public domain under the [Unlicense](LICENSE).
