# Contributing to Antenna

Thanks for your interest in contributing! Antenna is a macOS internet radio
player built with Swift 6 and SwiftUI.

## Quick Start

```bash
# Prerequisites
brew install just xcodegen swiftlint

# Clone and build
git clone https://github.com/brettchalupa/antenna.git
cd antenna
just generate   # Generate .xcodeproj from project.yml
just ok         # Format + lint + build (must pass)
just run        # Launch the app
```

## Development Workflow

**`just ok` is the mandatory gate check.** Run it after every change. It runs:

1. `swift format` — auto-formats all Swift files
2. `swiftlint` — checks for lint violations (must be zero)
3. `xcodebuild` — builds the project (must succeed)

Do not open a PR unless `just ok` passes.

### Useful Commands

```bash
just ok          # Format + lint + build (run before every commit)
just run         # Build and launch the app
just generate    # Regenerate .xcodeproj from project.yml
just rebuild     # Regenerate + build
just lint-fix    # Auto-fix lint violations
just clean       # Remove build artifacts
```

### Project Generation

The `.xcodeproj` is generated from `project.yml` using XcodeGen. **Never edit
the Xcode project directly.** If you need to add files, change build settings,
or modify targets, edit `project.yml` and run `just generate`.

## Code Style

### Formatting

`swift format` is the formatting authority. 2-space indentation, trailing commas
allowed. If SwiftLint and swift-format disagree, swift-format wins.

### Architecture

- **MVVM** with `@Observable` classes injected via `.environment()`
- **Swift 6 strict concurrency** is enabled — ViewModels that update UI must be
  `@MainActor`
- Use sequential `await` (not `async let`) in `@MainActor` classes to avoid data
  race warnings
- `ImageCache` is an `actor` for thread safety

### SwiftUI Patterns

- Use `@Bindable var` in view body when you need a `$binding` from an
  `@Observable`
- Use `.task(id:)` instead of `.onChange(of:)` when the action should fire on
  initial appear too
- Use `.foregroundColor()` (not `.foregroundStyle()`) for ternaries with mixed
  style types

## Pull Requests

- Keep PRs focused on a single change
- Include screenshots for UI changes
- `just ok` must pass
- Write a clear description of what changed and why

## Reporting Issues

When filing a bug report, please include:

- macOS version
- Antenna version
- Steps to reproduce
- Expected vs actual behavior
- Console output if relevant

## Adding New Files

- **New view**: Create in `Antenna/Views/`, wire into `ContentView.swift` if
  it's a new tab
- **New model**: Create in `Antenna/Models/`
- **New service**: Create in `Antenna/Services/`
- **New API endpoint**: Add to `RadioBrowserAPI.swift`

After adding files, run `just ok` to verify everything compiles.
