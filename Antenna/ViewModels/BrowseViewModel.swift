import SwiftUI

@MainActor
@Observable
final class BrowseViewModel {
  private let api = RadioBrowserAPI.shared

  var topVoted: [Station] = []
  var topClicked: [Station] = []
  var searchResults: [Station] = []
  var searchText = ""
  var selectedTag = ""
  var selectedCountryCode = ""

  var isLoadingDiscover = false
  var isLoadingSearch = false
  var discoverError: String?
  var searchError: String?

  var hasSearchQuery: Bool {
    !searchText.isEmpty || !selectedTag.isEmpty || !selectedCountryCode.isEmpty
  }

  func loadDiscover() async {
    guard topVoted.isEmpty else { return }
    isLoadingDiscover = true
    discoverError = nil

    do {
      let voted = try await api.getTopVoted(limit: 30)
      let clicked = try await api.getTopClicked(limit: 30)
      topVoted = voted
      topClicked = clicked
    } catch {
      discoverError = error.localizedDescription
    }

    isLoadingDiscover = false
  }

  func search() async {
    guard hasSearchQuery else {
      searchResults = []
      return
    }

    isLoadingSearch = true
    searchError = nil

    do {
      searchResults = try await api.searchStations(
        name: searchText,
        tag: selectedTag,
        countryCode: selectedCountryCode,
        limit: 50
      )
    } catch {
      searchError = error.localizedDescription
    }

    isLoadingSearch = false
  }

  func clearSearch() {
    searchText = ""
    selectedTag = ""
    selectedCountryCode = ""
    searchResults = []
    searchError = nil
  }
}
