import SwiftUI

struct AboutView: View {
  private var appVersion: String {
    let version =
      Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "?"
    let build =
      Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "?"
    return "\(version) (\(build))"
  }

  var body: some View {
    VStack(spacing: 16) {
      Image(nsImage: NSApplication.shared.applicationIconImage)
        .resizable()
        .frame(width: 96, height: 96)

      Text("Antenna")
        .font(.title)
        .fontWeight(.bold)

      Text("Version \(appVersion)")
        .font(.caption)
        .foregroundStyle(.secondary)

      Text(
        "A free, open-source internet radio player for macOS."
      )
      .multilineTextAlignment(.center)

      Divider()
        .frame(width: 200)

      VStack(spacing: 8) {
        Text("Made by Brett Chalupa")
          .font(.callout)

        Text("Released into the public domain under the Unlicense.")
          .font(.caption)
          .foregroundStyle(.secondary)
          .multilineTextAlignment(.center)
      }

      Divider()
        .frame(width: 200)

      VStack(spacing: 8) {
        Text("If you enjoy Antenna, consider supporting its development:")
          .font(.caption)
          .foregroundStyle(.secondary)
          .multilineTextAlignment(.center)

        Link(destination: URL(string: "https://buymeacoffee.com/brettchalupa")!) {
          Text("Buy Me a Coffee")
        }
        .font(.callout)
      }

      Divider()
        .frame(width: 200)

      HStack(spacing: 16) {
        Link(
          "Source Code",
          destination: URL(string: "https://github.com/brettchalupa/antenna")!
        )
        Link(
          "Report an Issue",
          destination: URL(
            string: "https://github.com/brettchalupa/antenna/issues")!
        )
      }
      .font(.caption)
    }
    .padding(24)
    .frame(width: 400)
  }
}
