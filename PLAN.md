# Antenna - macOS Internet Radio Player

A native macOS internet radio player inspired by [Shortwave](https://apps.gnome.org/Shortwave/), built with Swift and SwiftUI.

---

## Vision

A clean, minimal macOS menu-bar-friendly app for browsing, playing, and managing internet radio streams. Think "Spotify for internet radio" — fast to launch, easy to browse, and integrates natively with macOS media controls.

---

## Research Summary

### Station Directory: Radio Browser API

We'll use the **[Radio Browser API](https://api.radio-browser.info/)** — a free, open-source, community-driven database of 50,000+ internet radio stations. No API key required.

**Why Radio Browser over fmstream.org:**
- Free, no API key or application process required
- Public domain data license
- JSON REST API with excellent search/filter capabilities
- Already contains stations like WXPN (`https://wxpnhi.xpn.org/xpnhi`)
- Multiple mirror servers for reliability

**Key endpoints we'll use:**
| Endpoint | Purpose |
|---|---|
| `GET /json/stations/search?name=...&tag=...&country=...` | Search/browse stations |
| `GET /json/stations/topvote/<n>` | Popular stations for discovery |
| `GET /json/stations/topclick/<n>` | Trending stations |
| `GET /json/countries` | Country list for browsing |
| `GET /json/tags` | Genre/tag list for browsing |
| `GET /json/url/<stationuuid>` | Count click + get resolved stream URL |

**Station object fields we'll use:**
`stationuuid`, `name`, `url_resolved`, `homepage`, `favicon`, `countrycode`, `state`, `language`, `tags`, `codec`, `bitrate`, `votes`, `clickcount`, `lastcheckok`

**Server discovery:** DNS lookup on `all.api.radio-browser.info`, then randomize selection per their guidelines. User-Agent: `Antenna/<version>`.

### Audio Playback: AVPlayer

`AVPlayer` (AVFoundation) handles HTTP audio streaming natively — MP3, AAC, HLS all work out of the box. No third-party audio libraries needed.

### macOS Media Integration: MediaPlayer framework

- **`MPNowPlayingInfoCenter`** — displays station name/info in macOS Control Center and Touch Bar
- **`MPRemoteCommandCenter`** — handles play/pause/stop from media keys, headphone buttons, and Control Center
- On macOS, must explicitly set `playbackState` (unlike iOS where it's inferred from AVAudioSession)

### Development Environment

| Tool | Version |
|---|---|
| Xcode | 26.2 |
| Swift | 6.2.3 |
| macOS | 15.6.1 (Sequoia) |
| Homebrew | 5.0.14 |
| SwiftLint | Not installed (will add) |

---

## Architecture

### Pattern: MVVM

```
Antenna/
├── AntennaApp.swift              # App entry point
├── Models/
│   ├── Station.swift             # Station data model (Codable)
│   └── PlayerState.swift         # Playback state enum
├── Services/
│   ├── RadioBrowserAPI.swift     # API client for radio-browser.info
│   ├── AudioPlayer.swift         # AVPlayer wrapper + media controls
│   └── FavoritesStore.swift      # Persistence for favorites
├── ViewModels/
│   ├── BrowseViewModel.swift     # Search & browse logic
│   ├── FavoritesViewModel.swift  # Favorites management
│   └── PlayerViewModel.swift     # Playback state management
├── Views/
│   ├── ContentView.swift         # Main window with sidebar navigation
│   ├── BrowseView.swift          # Station directory browser
│   ├── SearchView.swift          # Search interface
│   ├── FavoritesView.swift       # Saved stations list
│   ├── StationRowView.swift      # Station list item
│   ├── PlayerBarView.swift       # Now-playing bar (bottom of window)
│   └── AddStationView.swift      # Custom URL entry sheet
├── Resources/
│   └── Assets.xcassets           # App icon, colors
├── Info.plist
└── Antenna.entitlements          # Network access entitlement
```

### Data Flow

```
RadioBrowserAPI  ──→  BrowseViewModel  ──→  BrowseView
                                              │
                                         user taps play
                                              │
                                              ▼
FavoritesStore  ←──  PlayerViewModel  ──→  AudioPlayer
                          │                    │
                          ▼                    ▼
                    PlayerBarView      MPNowPlayingInfoCenter
                                       MPRemoteCommandCenter
```

---

## Features & Implementation Plan

### Phase 1: Project Scaffolding & Audio Playback
_Get a working app that can play a hardcoded stream URL._

1. **Create Xcode project** via `xcodebuild` / Swift Package Manager
   - macOS app target, SwiftUI lifecycle, minimum deployment: macOS 14
   - Add entitlements: `com.apple.security.network.client` (outgoing connections)

2. **AudioPlayer service**
   - Wrap `AVPlayer` for streaming playback
   - Methods: `play(url:)`, `pause()`, `resume()`, `stop()`
   - Observe `AVPlayerItem.status` and `AVPlayer.timeControlStatus` for state
   - Expose `@Published` state: `.idle`, `.loading`, `.playing`, `.paused`, `.error`

3. **Minimal UI**
   - Single window with a text field for URL + play/pause button
   - Now-playing bar at the bottom showing station name + playback controls
   - Test with `https://wxpnhi.xpn.org/xpnhi-nopreroll`

### Phase 2: Media Controls Integration

4. **MPNowPlayingInfoCenter setup**
   - Set `nowPlayingInfo` dict with: `MPMediaItemPropertyTitle` (station name), `MPNowPlayingInfoPropertyIsLiveStream` = true
   - Set `playbackState` explicitly (required on macOS)

5. **MPRemoteCommandCenter setup**
   - Register handlers for: `playCommand`, `pauseCommand`, `togglePlayPauseCommand`, `stopCommand`
   - Wire to AudioPlayer service

### Phase 3: Station Directory & Browsing

6. **RadioBrowserAPI service**
   - Async/await based `URLSession` client
   - Server discovery: resolve `all.api.radio-browser.info` via DNS, pick random server
   - Methods:
     - `searchStations(name:tag:country:limit:offset:)` → `[Station]`
     - `getTopVoted(limit:)` → `[Station]`
     - `getTopClicked(limit:)` → `[Station]`
     - `getCountries()` → `[Country]`
     - `getTags(limit:)` → `[Tag]`
     - `clickStation(uuid:)` → resolved URL
   - User-Agent header: `Antenna/0.1`
   - Proper error handling with typed errors

7. **Station model**
   ```swift
   struct Station: Codable, Identifiable, Hashable {
       let stationuuid: String
       let name: String
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
   }
   ```

8. **Browse UI**
   - Sidebar navigation: Discover, Search, Favorites
   - Discover tab: Top Voted + Top Clicked stations in sections
   - Search tab: Text search with optional filters (country, tag)
   - Station rows: Name, tags, country flag, bitrate badge, play button
   - Async favicon loading with `AsyncImage`
   - Pagination via infinite scroll (offset-based)

### Phase 4: Favorites & Custom Stations

9. **FavoritesStore service**
   - Persist to `~/Library/Application Support/Antenna/favorites.json`
   - Store full `Station` objects (works for both API stations and custom ones)
   - Methods: `add(station:)`, `remove(uuid:)`, `isFavorite(uuid:)`, `getAll()`
   - `@Published var favorites: [Station]`

10. **Add Custom Station sheet**
    - Text fields: Name (required), Stream URL (required), Homepage (optional), Tags (optional)
    - Validate URL format and optionally test stream connectivity
    - Generate a local UUID for custom stations
    - Auto-add to favorites on save

11. **Favorites UI**
    - List of favorited stations with remove/unfavorite action
    - "Add Custom Station" button at top
    - Drag to reorder (optional, stretch goal)

### Phase 5: Polish & Refinements

12. **Favicon caching** — cache downloaded favicons to disk
13. **Error states** — connection errors, stream failures, empty states
14. **Keyboard shortcuts** — Space for play/pause, Cmd+F for search
15. **App icon** — radio antenna themed icon

---

## CLI Development Workflow

### Project Creation
```bash
# We'll create the Xcode project from the CLI
# Option A: Use `swift package init` + add to Xcode workspace
# Option B: Generate project with a script

# For a SwiftUI macOS app, we'll use xcodebuild with a Package.swift
# that defines an executable target, or create the .xcodeproj manually
```

### Daily Commands

```bash
# Build the app
xcodebuild -project Antenna.xcodeproj -scheme Antenna -configuration Debug build

# Run tests
xcodebuild -project Antenna.xcodeproj -scheme Antenna -configuration Debug test

# Build and run (debug)
xcodebuild -project Antenna.xcodeproj -scheme Antenna -configuration Debug build && \
  open build/Debug/Antenna.app

# Clean build
xcodebuild -project Antenna.xcodeproj -scheme Antenna clean

# Lint (after installing swiftlint)
brew install swiftlint
swiftlint --config .swiftlint.yml

# Format
swift format --in-place --recursive Sources/
```

### Makefile (for convenience)
We'll create a `Makefile` with targets: `build`, `run`, `test`, `lint`, `clean`, `format`.

### SwiftLint Configuration
Minimal `.swiftlint.yml` with sensible defaults — not too strict for a learning project.

---

## Technical Decisions & Rationale

| Decision | Choice | Why |
|---|---|---|
| UI Framework | SwiftUI | Modern, declarative, less boilerplate than AppKit |
| Audio | AVPlayer | Built-in HTTP streaming, no dependencies needed |
| API | Radio Browser | Free, open, no API key, 50k+ stations |
| Persistence | JSON file | Simple, no CoreData complexity for a list of favorites |
| Architecture | MVVM | Natural fit for SwiftUI's data binding |
| Min macOS | 14 (Sonoma) | Access to latest SwiftUI features |
| Concurrency | async/await | Modern Swift concurrency, cleaner than callbacks |

---

## Implementation Order

```
Phase 1  ████████░░░░░░░░░░░░  Project setup + audio playback
Phase 2  ████████████░░░░░░░░  Media keys + Control Center
Phase 3  ████████████████░░░░  Browse stations + search
Phase 4  ████████████████████  Favorites + custom stations
Phase 5  ████████████████████  Polish
```

**Estimated phases:** 5 phases, each buildable and testable independently.

Each phase ends with a working app — Phase 1 alone gives you a functional radio player.

---

## Open Questions

1. **Window style** — Standard window, or also a mini-player / menu-bar mode? (Start with standard window, can add mini-player later)
2. **Recordings** — Shortwave supports recording streams. Defer to a future version?
3. **Network device playback** — Shortwave supports Chromecast. Out of scope for v1?

---

## References

- [Radio Browser API Docs](https://de2.api.radio-browser.info/)
- [AVPlayer Docs](https://developer.apple.com/documentation/avfoundation/avplayer)
- [MPNowPlayingInfoCenter](https://developer.apple.com/documentation/mediaplayer/mpnowplayinginfocenter)
- [MPRemoteCommandCenter](https://developer.apple.com/documentation/mediaplayer/mpremotecommandcenter)
- [Shortwave (inspiration)](https://apps.gnome.org/Shortwave/)
- [fmstream.org](https://fmstream.org/index.php) — alternative stream directory for reference
