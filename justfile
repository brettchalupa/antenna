# Antenna - macOS Internet Radio Player

# Run all checks: format, lint, build, test. Must pass before committing.
ok: format lint build

# Generate the Xcode project from project.yml
generate:
    xcodegen generate

# Format Swift source files
format:
    swift format --in-place --recursive Antenna/

# Check formatting without modifying files
format-check:
    swift format --recursive Antenna/ 2>&1 | diff - /dev/null

# Lint with SwiftLint
lint:
    swiftlint --config .swiftlint.yml

# Lint and auto-fix
lint-fix:
    swiftlint --config .swiftlint.yml --fix

# Build the app (debug)
build:
    xcodebuild -project Antenna.xcodeproj -scheme Antenna -configuration Debug build SYMROOT=build 2>&1 | tail -5

# Build and run
run: build
    open build/Debug/Antenna.app

# Run tests
test:
    xcodebuild -project Antenna.xcodeproj -scheme Antenna -configuration Debug test SYMROOT=build

# Clean build artifacts
clean:
    xcodebuild -project Antenna.xcodeproj -scheme Antenna clean SYMROOT=build
    rm -rf build DerivedData

# Regenerate project and build
rebuild: generate build

# Open in Xcode
open:
    open Antenna.xcodeproj

# List available recipes
default:
    @just --list
