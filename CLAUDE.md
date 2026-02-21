# Antenna - Agent Guide

## What is this?

A native macOS internet radio player built with Swift 6 and SwiftUI. MVVM
architecture. Uses the Radio Browser API (free, no API key) for 50k+ stations.
Audio via AVPlayer with macOS media control integration.

## Mandatory: Run `just ok` after every code change

```bash
just ok   # format -> lint -> build (must all pass, zero violations)
```

Do not skip this. Do not commit without it passing.

## Project structure

```
Antenna/
├── AntennaApp.swift              # @main entry, owns all state, menu commands
├── Models/
│   ├── Station.swift             # Codable model (Radio Browser API shape)
│   └── PlayerState.swift         # .idle | .loading | .playing | .paused | .error
├── Services/
│   ├── AudioPlayer.swift         # AVPlayer wrapper, KVO, MPRemoteCommandCenter, MPNowPlayingInfoCenter
│   ├── RadioBrowserAPI.swift     # Async API client, DNS-based server discovery
│   ├── FavoritesStore.swift      # JSON persistence to ~/Library/Application Support/Antenna/
│   └── ImageCache.swift          # Actor-based favicon cache (memory + disk)
├── ViewModels/
│   ├── PlayerViewModel.swift     # Bridges AudioPlayer to views
│   └── BrowseViewModel.swift     # Drives Discover + Search tabs (@MainActor)
├── Views/
│   ├── ContentView.swift         # NavigationSplitView with sidebar
│   ├── BrowseView.swift          # Discover tab (Popular/Trending)
│   ├── SearchView.swift          # Search tab with focus management
│   ├── FavoritesView.swift       # Favorites list + add custom station
│   ├── StationRowView.swift      # Station row with favicon, tags, heart toggle
│   ├── PlayerBarView.swift       # Bottom bar: now-playing info, volume, controls
│   ├── AddStationView.swift      # Sheet for custom stream URL entry
│   └── CachedAsyncImage.swift    # AsyncImage replacement using ImageCache
└── Resources/
    └── Assets.xcassets/          # App icon (generated), accent color
```

Other files:

- `project.yml` — XcodeGen spec (run `just generate` to regenerate .xcodeproj)
- `justfile` — task runner recipes
- `.swiftlint.yml` — linter config
- `scripts/generate_icon.swift` — programmatic app icon generation

## Key commands

```bash
just ok          # MANDATORY gate check: format + lint + build
just run         # Build and launch the app
just generate    # Regenerate .xcodeproj from project.yml
just rebuild     # generate + build
just lint-fix    # Auto-fix lint violations
just clean       # Remove all build artifacts
```

## Code conventions

### Formatting authority: `swift format`

- 2-space indentation, trailing commas allowed
- SwiftLint rules that conflict with swift-format are disabled (see
  .swiftlint.yml)
- If swiftlint and swift-format disagree, swift-format wins

### Swift 6 strict concurrency

- `SWIFT_STRICT_CONCURRENCY: complete` is enabled
- ViewModels that update UI state must be `@MainActor` (e.g. BrowseViewModel)
- Use sequential `await` (not `async let`) in `@MainActor` classes to avoid
  "sending self risks data races"
- ImageCache is an `actor` for thread safety

### SwiftUI patterns

- ViewModels are `@Observable` classes, injected via `.environment()`
- Use `@Bindable var` in view body when you need a `$binding` from an
  `@Observable`
- Use `.task(id:)` instead of `.onChange(of:)` when you need the action to fire
  on initial appear too
- Use `.foregroundColor()` (not `.foregroundStyle()`) for ternaries with mixed
  style types

### Data persistence

- Favorites: `~/Library/Application Support/Antenna/favorites.json`
- Favicon cache: `~/Library/Caches/Antenna/favicons/` (SHA256 hashed filenames)
- Volume: `UserDefaults` key `"playerVolume"`

## Common pitfalls

- **KVO + DispatchQueue.main.async race**: AudioPlayer's KVO observers dispatch
  async. When stopping, nil out observations _before_ calling `player?.pause()`
  to prevent state from being overwritten. Also guard against `.idle` state in
  the paused observer.
- **Retina icon sizing**: Use `NSBitmapImageRep` with explicit pixel dimensions
  for icon generation, not `NSImage` (which renders in points and doubles on
  retina).
- **List selection binding type**: `List(selection:)` binds to the ID type. If
  using an enum as both item and selection, pass `id: \.self`.
- **Xcode project out of sync**: If you modify `project.yml`, run
  `just generate` then `just build`. The .xcodeproj is generated, not
  hand-edited.

## Adding a new view

1. Create the SwiftUI view file in `Antenna/Views/`
2. Wire it into `ContentView.swift` if it's a new tab (add to `SidebarItem`
   enum)
3. Run `just ok`

## Adding a new API endpoint

1. Add the method to `RadioBrowserAPI.swift`
2. Add any new model types to `Antenna/Models/`
3. Call from the appropriate ViewModel
4. Run `just ok`
