# Antenna — Roadmap to v1.0 Open Source Release

## Current State

Antenna is a working macOS internet radio player with:

- AVPlayer streaming (play/pause/stop/volume with UserDefaults persistence)
- 50k+ stations via Radio Browser API (popular, trending, search)
- Favorites with JSON persistence, drag-to-reorder, and custom station URLs
- Media key integration (MPRemoteCommandCenter + MPNowPlayingInfoCenter)
- Keyboard shortcuts (Cmd+P, Cmd+., Cmd+F, Cmd+1/2/3)
- Actor-based favicon cache (memory + disk)
- Swift 6 strict concurrency, MVVM with @Observable, XcodeGen

## Competitive Landscape

| App        | Price            | Native?        | Stations  |   Open Source?   |
| ---------- | ---------------- | -------------- | --------- | :--------------: |
| Broadcasts | Free / $5-10     | Catalyst       | 6k+       |        No        |
| Triode     | Free / $10-20/yr | Swift          | Thousands |        No        |
| Eter       | Free / $3-9      | SwiftUI        | 40k+      |        No        |
| Radium     | ~$10             | AppKit         | 20k+      |    No (dead)     |
| myTuner    | Free / $5-10     | Cross-platform | 50k+      |        No        |
| TuneIn     | Free / $10/mo    | Unknown        | 100k+     |        No        |
| SonicWeb   | ~$7-9            | Native         | 2k+       |        No        |
| Radiola    | Free             | Native         | BYO       |  Yes (minimal)   |
| Shortwave  | Free             | Rust+GTK       | 50k+      | Yes (Linux only) |

**The gap**: No open-source, full-featured, SwiftUI-native macOS radio player
exists. Antenna can be the "Shortwave for macOS."

---

## Milestone 1: Essential Features

_Close the gap with Broadcasts, Triode, and Eter on the features users complain
about most._

### 1.1 Sleep Timer

- [ ] Add `SleepTimer` service (countdown → `AudioPlayer.stop()`)
- [ ] Preset durations: 15, 30, 45, 60, 90 min + custom
- [ ] Timer button in `PlayerBarView` with remaining time indicator
- [ ] Cancel timer option

### 1.2 ICY Stream Metadata (Now Playing Track Info)

- [ ] Observe `AVPlayerItem.timedMetadata` for ICY metadata (artist/track)
- [ ] Display "Artist — Track" in `PlayerBarView` when available
- [ ] Update `MPNowPlayingInfoCenter` with track info
- [ ] Fall back to station name when no metadata

### 1.3 Auto-Reconnect on Stream Failure

- [ ] Detect `.failed` status on AVPlayerItem
- [ ] Retry up to 3 times with exponential backoff (2s, 4s, 8s)
- [ ] Show "Reconnecting..." state in UI
- [ ] Give up and show error after max retries

### 1.4 Resume Last Station on Launch

- [ ] Persist last-played station UUID to UserDefaults
- [ ] On app launch, restore the last station (paused state, ready to play)
- [ ] Optional: auto-play on launch (preference toggle)

### 1.5 Browse by Country and Genre

- [ ] `getCountries()` and `getTags()` are already in `RadioBrowserAPI.swift` —
      surface them in UI
- [ ] Add country picker to Discover or as a filter in Search
- [ ] Add genre/tag picker similarly
- [ ] Show station count per country/genre

### 1.6 Stream Quality Indicator

- [ ] Display codec and bitrate in `PlayerBarView` when playing
- [ ] Station model already has `codec` and `bitrate` fields — just wire to UI

---

## Milestone 2: Power User Features

_Features that make Antenna stand out and feel like a daily-driver app._

### 2.1 Menu Bar Mini Player

- [ ] Add a menu bar extra with `MenuBarExtra` (macOS 13+)
- [ ] Show current station name + play/pause/stop controls
- [ ] Volume slider in popover
- [ ] Quick-switch between recent/favorite stations
- [ ] Option to hide Dock icon when menu bar mode is active

### 2.2 Listening History / Track Log

- [ ] Log station + track metadata with timestamps
- [ ] Persist to `~/Library/Application Support/Antenna/history.json`
- [ ] New sidebar tab or section showing recent listening history
- [ ] Tap a history entry to replay that station

### 2.3 AirPlay 2 Support

- [ ] Add `AVRoutePickerView` button to `PlayerBarView`
- [ ] Wrap in `NSViewRepresentable` for SwiftUI

### 2.5 M3U / PLS Import & Export

- [ ] Parse M3U and PLS playlist formats
- [ ] Import: File > Import Stations menu item
- [ ] Export: File > Export Favorites menu item
- [ ] Map imported entries to Station model

---

## Milestone 3: Differentiators

_Features that no or few competitors offer — reasons to choose Antenna._

### 3.1 ShazamKit Integration

- [ ] Use Apple's ShazamKit framework to identify currently playing track
- [ ] "Identify Song" button in player bar
- [ ] Show album art, song title, artist from Shazam result
- [ ] Link to Apple Music / open in Music app

### 3.2 Apple Shortcuts Integration

- [ ] Define App Intents: "Play Station", "Stop Playback", "What's Playing"
- [ ] Register with Shortcuts app
- [ ] Enable Siri voice commands

### 3.3 Global Hotkeys

- [ ] Play/pause/stop from any app (not just when Antenna is focused)
- [ ] Use `NSEvent.addGlobalMonitorForEvents` or Carbon hotkey API
- [ ] Configurable in preferences

### 3.4 Stream Recording (Stretch)

- [ ] Record current stream to local file (MP3/AAC)
- [ ] Auto-split by track using ICY metadata boundaries
- [ ] Save to user-chosen directory
- [ ] Note: Legal considerations vary by jurisdiction — add disclaimer

### 3.5 Equalizer (Stretch)

- [ ] Switch from AVPlayer to AVAudioEngine pipeline
- [ ] Add AVAudioUnitEQ with preset bands
- [ ] Per-station EQ presets
- [ ] Note: High effort — requires rearchitecting audio pipeline

---

## Milestone 4: Open Source Release Prep

_Everything needed to ship v1.0 as a public open-source project._

### 4.1 License

- [x] Add `LICENSE` file — **Unlicense** (public domain)
- [ ] ~~Add license header comment to source files~~ (not needed for Unlicense)

### 4.2 Code Cleanup

- [x] Audit repo for secrets, personal paths, TODOs — clean
- [x] Remove any hardcoded test data — none found
- [x] Ensure `.gitignore` covers build artifacts, .xcodeproj internals, secrets
      — already covered
- [ ] Review all `print()` statements — replace with proper logging or remove

### 4.3 README

- [ ] Hero screenshot of the app
- [x] One-line description + feature list
- [ ] Download section (GitHub Releases, Homebrew) — add once first release is
      published
- [x] Build-from-source instructions
- [x] Link to CONTRIBUTING.md and LICENSE

### 4.4 CONTRIBUTING.md

- [x] Prerequisites and setup instructions
- [x] `just ok` as the mandatory gate
- [x] Code style guide (swift-format is authority, MVVM, @Observable patterns)
- [x] PR guidelines (focused changes, screenshots for UI, `just ok` must pass)
- [x] Issue reporting guidelines

### 4.5 GitHub Infrastructure

- [x] Issue templates: Bug Report + Feature Request (YAML forms)
- [x] PR template with checklist
- [ ] CODE_OF_CONDUCT.md (Contributor Covenant)
- [ ] GitHub Topics: `macos`, `swift`, `swiftui`, `radio`, `internet-radio`,
      `open-source`
- [ ] Social preview image (1280x640)

### 4.6 CI / GitHub Actions

- [x] CI workflow on push/PR to main:
  - `swift format` check (fail if formatting changes needed)
  - `swiftlint --strict`
  - `xcodebuild` build
- [ ] Release workflow on tag push (`v*`):
  - Archive + export
  - Code sign + notarize
  - Create DMG (via `create-dmg`)
  - Upload to GitHub Release

### 4.7 Code Signing & Notarization

- [ ] Apple Developer Program ($99/year) — required for signing and notarization
- [ ] Developer ID certificate for direct distribution
- [ ] Notarize with `xcrun notarytool` — without this, Gatekeeper blocks the app
- [ ] Staple notarization ticket to DMG

### 4.8 Distribution

- [ ] **GitHub Releases** — signed, notarized DMG (primary channel)
- [ ] **Homebrew Cask** — submit PR to homebrew-cask repo after first stable
      release
- [ ] **Mac App Store** (optional) — requires sandboxing entitlements, $99/yr
      account
  - Consider the Maccy model: free on GitHub, small fee on App Store to offset
    costs

---

## Milestone 5: Launch & Community

### 5.1 Launch Checklist

- [ ] Tag `v1.0.0`
- [ ] Upload signed DMG to GitHub Releases
- [ ] Post to **Hacker News** ("Show HN: Antenna — open-source internet radio
      for macOS")
- [ ] Post to **r/macapps** with screenshot and download link
- [ ] Post to **r/opensource**, **r/swift**, **r/SwiftUI**
- [ ] Submit to **Product Hunt**

### 5.2 Post-Launch

- [ ] Submit Homebrew Cask PR
- [ ] Respond to issues quickly in the first 2 weeks
- [ ] Label issues with "good first issue" and "help wanted"
- [ ] Submit to newsletters: iOS Dev Weekly, Console.dev, Changelog
- [ ] Set up GitHub Sponsors
- [ ] Add Sparkle framework for auto-updates (direct download users)
- [ ] Enable GitHub Discussions for Q&A
- [ ] Maintain CHANGELOG.md with each release

---

## Milestone 6: Beyond

### 6.1 Favorite sync

- [ ] Via built in Apple SDKs like iCloud Drive or whatever is available

### 6.2 iPadOS, iOS, and TVOS support

- [ ] explore what it'd be like to launch the app for more platforms

---

## Priority Order

Work through milestones roughly in order, but items within each milestone can be
tackled independently:

```
Milestone 1 (Essential Features)     — must-have for v1.0
Milestone 4 (Open Source Prep)       — must-have for v1.0
Milestone 2 (Power User Features)    — should-have for v1.0, some can slip to v1.1
Milestone 5 (Launch)                 — do once 1 + 4 are done
Milestone 3 (Differentiators)        — v1.1+ (nice-to-have, post-launch)
```

Milestones 1 and 4 can be worked on in parallel — features and release prep are
independent tracks.
