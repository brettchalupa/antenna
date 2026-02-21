# Releasing Antenna

Steps for creating a new release.

## Prerequisites

- Apple Developer Program membership
- Signed into your Apple ID in **Xcode > Settings > Accounts**
- Developer ID Application certificate (create via Xcode > Settings > Accounts > Manage Certificates > "+")
- `create-dmg` installed: `brew install create-dmg`

## Versioning

There are two version fields in `project.yml`:

- **`MARKETING_VERSION`** — the user-facing version string (e.g., `"0.1.0"`).
  Shows up in the About screen, App Store, and GitHub Releases. Follows semantic
  versioning.
- **`CURRENT_PROJECT_VERSION`** — an always-incrementing integer (the build
  number). Goes up by 1 with every release, regardless of the marketing version.
  Used by the App Store and auto-updaters to determine "is this newer?" since
  comparing integers is unambiguous.

Example progression:

| Release       | `MARKETING_VERSION` | `CURRENT_PROJECT_VERSION` |
| ------------- | ------------------- | ------------------------- |
| First release | `0.1.0`             | `1`                       |
| Bug fix       | `0.1.1`             | `2`                       |
| New features  | `0.2.0`             | `3`                       |
| v1 launch     | `1.0.0`             | `4`                       |

The marketing version can jump around, but the build number should only ever go
up.

## 1. Prepare the release

Bump both versions in `project.yml`:

```yaml
MARKETING_VERSION: "0.2.0"
CURRENT_PROJECT_VERSION: 2
```

Regenerate the Xcode project and verify the build:

```bash
just generate
just ok
```

Commit the version bump:

```bash
git add project.yml
git commit -m "Bump version to 0.2.0"
```

## 2. Archive in Xcode

1. Open the project: `just open`
2. In Xcode, make sure the **Antenna** scheme is selected and the destination is **My Mac**
3. Select your team in **Antenna target > Signing & Capabilities** if not already set
4. **Product > Archive**
5. Wait for the archive to complete — the Organizer window will open

## 3. Distribute (sign + notarize)

1. In the Organizer window, select the new archive
2. Click **Distribute App**
3. Select **Direct Distribution**
4. Xcode will automatically:
   - Sign with your Developer ID Application certificate
   - Upload to Apple for notarization
   - Wait for notarization to complete
   - Staple the notarization ticket
5. Choose an export location — Xcode exports a signed, notarized `Antenna.app`

## 4. Create the DMG

```bash
create-dmg \
  --volname "Antenna" \
  --window-pos 200 120 \
  --window-size 600 400 \
  --icon-size 100 \
  --icon "Antenna.app" 175 190 \
  --app-drop-link 425 190 \
  --hide-extension "Antenna.app" \
  "Antenna-0.2.0.dmg" \
  "/path/to/exported/Antenna.app"
```

Replace `/path/to/exported/Antenna.app` with wherever Xcode exported the app.

## 5. Tag and push

```bash
git tag v0.2.0
git push origin main --tags
```

## 6. Create the GitHub Release

```bash
gh release create v0.2.0 Antenna-0.2.0.dmg \
  --title "Antenna v0.2.0" \
  --notes "Release notes here"
```

Or create the release through the GitHub web UI and upload the DMG.

## 7. Post-release

- Update Homebrew Cask (once listed): PR to bump version + SHA256
- Announce on relevant channels

## Notes

- **Notarization can take a few minutes.** Xcode shows progress in the Organizer.
- **If notarization fails**, Xcode will show the error in the Organizer. Click "Show Logs" for details.
- **project.yml has signing disabled** (`CODE_SIGN_IDENTITY: "-"`). Xcode overrides this when you select a team in Signing & Capabilities. This is fine — CI builds unsigned, release builds are signed via Xcode.
