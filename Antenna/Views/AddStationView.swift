import SwiftUI

struct AddStationView: View {
  @Environment(FavoritesStore.self) private var favoritesStore
  @Environment(\.dismiss) private var dismiss

  @State private var name = ""
  @State private var streamURL = ""
  @State private var validationError: String?

  private var isValid: Bool {
    !name.trimmingCharacters(in: .whitespaces).isEmpty
      && !streamURL.trimmingCharacters(in: .whitespaces).isEmpty
  }

  var body: some View {
    VStack(spacing: 0) {
      // Header
      HStack {
        Text("Add Custom Station")
          .font(.headline)
        Spacer()
        Button {
          dismiss()
        } label: {
          Image(systemName: "xmark.circle.fill")
            .foregroundStyle(.secondary)
        }
        .buttonStyle(.borderless)
      }
      .padding()

      Divider()

      // Form
      VStack(alignment: .leading, spacing: 16) {
        VStack(alignment: .leading, spacing: 4) {
          Text("Station Name")
            .font(.caption)
            .foregroundStyle(.secondary)
          TextField("e.g. WXPN 88.5", text: $name)
            .textFieldStyle(.roundedBorder)
        }

        VStack(alignment: .leading, spacing: 4) {
          Text("Stream URL")
            .font(.caption)
            .foregroundStyle(.secondary)
          TextField("e.g. https://wxpnhi.xpn.org/xpnhi-nopreroll", text: $streamURL)
            .textFieldStyle(.roundedBorder)
        }

        if let validationError {
          Text(validationError)
            .font(.caption)
            .foregroundStyle(.red)
        }
      }
      .padding()

      Divider()

      // Actions
      HStack {
        Spacer()
        Button("Cancel") {
          dismiss()
        }
        .keyboardShortcut(.cancelAction)

        Button("Add to Favorites") {
          addStation()
        }
        .keyboardShortcut(.defaultAction)
        .buttonStyle(.borderedProminent)
        .disabled(!isValid)
      }
      .padding()
    }
    .frame(width: 420)
  }

  private func addStation() {
    let trimmedURL = streamURL.trimmingCharacters(in: .whitespaces)
    guard URL(string: trimmedURL) != nil else {
      validationError = "Please enter a valid URL"
      return
    }

    let station = Station.custom(
      name: name.trimmingCharacters(in: .whitespaces),
      url: trimmedURL
    )
    favoritesStore.add(station)
    dismiss()
  }
}
