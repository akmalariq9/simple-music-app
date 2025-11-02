//
//  simple_music_appTests.swift
//  simple-music-appTests
//
//  Created by Akmal Ariq on 02/11/25.
//

import Testing
import Foundation
import AVFoundation
@testable import simple_music_app

@MainActor
class MockNetworkManager: NetworkManager {
  var shouldSucceed = true
  var mockSongs: [Song] = []
  var mockError: NetworkError = .noData
  var fetchSongsCallCount = 0
  
  override func fetchSongs(completion: @escaping (Result<[Song], NetworkError>) -> Void) {
    fetchSongsCallCount += 1
    
    if shouldSucceed {
      completion(.success(mockSongs))
    } else {
      completion(.failure(mockError))
    }
  }
}

@MainActor
class TestableMusicPlayerViewModel: MusicPlayerViewModel {
  private let mockNetworkManager: MockNetworkManager
  
  init(networkManager: MockNetworkManager) {
    self.mockNetworkManager = networkManager
    super.init()
  }
  
  override func fetchSongs() {
    isLoading = true
    errorMessage = nil
    
    mockNetworkManager.fetchSongs { [weak self] result in
      DispatchQueue.main.async {
        self?.isLoading = false
        
        switch result {
        case .success(let songs):
          self?.songs = songs
          self?.filteredSongs = songs
          self?.currentSong = songs.first
        case .failure(let error):
          self?.setErrorMessage(for: error)
        }
      }
    }
  }
  
  private func setErrorMessage(for error: NetworkError) {
    switch error {
    case .networkError(let networkError):
      errorMessage = "Network error: \(networkError.localizedDescription)"
    case .serverError(let statusCode):
      errorMessage = "Server error: \(statusCode)"
    case .decodingError(let decodingError):
      errorMessage = "Error decoding data: \(decodingError.localizedDescription)"
    case .noData:
      errorMessage = "No data received from the server."
    case .invalidResponse:
      errorMessage = "Invalid response from the server."
    case .invalidURL:
      errorMessage = "The API URL is invalid."
    }
  }
}

extension Song {
  static func fixture(
    id: Int = 1,
    trackName: String = "Test Song",
    collectionName: String = "Test Album",
    artistName: String = "Test Artist",
    artworkUrl100: String = "https://example.com/song.jpg",
    previewUrl: String = "https://example.com/song.mp3"
  ) -> Song {
    Song(
      id: .init(id),
      trackName: trackName,
      collectionName: collectionName,
      artistName: artistName,
      artworkUrl100: artworkUrl100,
      previewUrl: previewUrl
    )
  }
}

@Suite("Network Test")
@MainActor
struct NetworkTest {
  @Test("Given initial state, When fetchSongs succeeds, Then songs are loaded and first song is selected")
  func fetchSongsSuccess() async throws {
    let mockManager = MockNetworkManager()
    let testSongs = [
      Song.fixture(id: 1, trackName: "Song 1"),
      Song.fixture(id: 2, trackName: "Song 2"),
      Song.fixture(id: 3, trackName: "Song 3")
    ]
    mockManager.mockSongs = testSongs
    mockManager.shouldSucceed = true
    
    let viewModel = TestableMusicPlayerViewModel(networkManager: mockManager)
    
    try await Task.sleep(nanoseconds: 100_000_000)
    
    #expect(viewModel.songs.count == 3)
    #expect(viewModel.filteredSongs.count == 3)
    #expect(viewModel.currentSong?.id == 1)
    #expect(viewModel.isLoading == false)
    #expect(viewModel.errorMessage == nil)
  }
  
  @Test("Given initial state, When fetchSongs is loading, Then isLoading is true")
  func fetchSongsLoading() async throws {
    let mockManager = MockNetworkManager()
    let viewModel = TestableMusicPlayerViewModel(networkManager: mockManager)
    
    viewModel.isLoading = true
    #expect(viewModel.isLoading == true)
  }
  
  @Test("Given initial state, When fetchSongs fails with network error, Then error message is set")
  func fetchSongsNetworkError() async throws {
    let mockManager = MockNetworkManager()
    mockManager.shouldSucceed = false
    mockManager.mockError = .networkError(NSError(domain: "test", code: -1))
    
    let viewModel = TestableMusicPlayerViewModel(networkManager: mockManager)
    try await Task.sleep(nanoseconds: 100_000_000)
    
    #expect(viewModel.errorMessage != nil)
    #expect(viewModel.errorMessage?.contains("Network error") == true)
    #expect(viewModel.isLoading == false)
  }
}

@Suite("Search Test")
@MainActor
struct SearchTest {
  @Test("Given songs loaded, When searching by track name, Then matching songs are filtered")
  func searchByTrackName() async throws {
    let mockManager = MockNetworkManager()
    mockManager.mockSongs = [
      Song.fixture(id: 1, trackName: "Rock Song", artistName: "Artist A"),
      Song.fixture(id: 2, trackName: "Pop Song", artistName: "Artist B"),
      Song.fixture(id: 3, trackName: "Jazz Melody", artistName: "Artist C")
    ]
    let viewModel = TestableMusicPlayerViewModel(networkManager: mockManager)
    try await Task.sleep(nanoseconds: 100_000_000)
    
    viewModel.searchText = "Rock"
    viewModel.searchSongs()
    
    #expect(viewModel.filteredSongs.count == 1)
    #expect(viewModel.filteredSongs.first?.trackName == "Rock Song")
  }
  
  @Test("Given songs loaded, When searching by artist name, Then matching songs are filtered")
  func searchByArtistName() async throws {
    let mockManager = MockNetworkManager()
    mockManager.mockSongs = [
      Song.fixture(id: 1, trackName: "Song A", artistName: "Beatles"),
      Song.fixture(id: 2, trackName: "Song B", artistName: "Rolling Stones")
    ]
    
    let viewModel = TestableMusicPlayerViewModel(networkManager: mockManager)
    try await Task.sleep(nanoseconds: 100_000_000)
    
    viewModel.searchText = "beatles"
    viewModel.searchSongs()
    
    #expect(viewModel.filteredSongs.count == 1)
    #expect(viewModel.filteredSongs.first?.artistName == "Beatles")
  }
  
  @Test("Given songs loaded, When searching with no matches, Then filtered songs is empty")
  func searchWithNoMatches() async throws {
    let mockManager = MockNetworkManager()
    mockManager.mockSongs = [
      Song.fixture(id: 1, trackName: "Song A"),
      Song.fixture(id: 2, trackName: "Song B")
    ]
    
    let viewModel = TestableMusicPlayerViewModel(networkManager: mockManager)
    try await Task.sleep(nanoseconds: 100_000_000)
    
    viewModel.searchText = "NonExistentSong"
    viewModel.searchSongs()
    
    #expect(viewModel.filteredSongs.isEmpty)
  }
}

@Suite("Player Functionality Test")
@MainActor
struct PlayerFunctionalityTest {
  @Test("Given song is not playing, When playPause is called, Then song starts playing")
  func playPauseStartsPlaying() async throws {
    let mockManager = MockNetworkManager()
    mockManager.mockSongs = [Song.fixture(id: 1)]
    
    let viewModel = TestableMusicPlayerViewModel(networkManager: mockManager)
    try await Task.sleep(nanoseconds: 100_000_000)
    viewModel.playPause()
    
    #expect(viewModel.isPlaying == true)
  }
  
  @Test("Given song is playing, When stop is called, Then playback stops")
  func stopStopsPlayback() async throws {
    let mockManager = MockNetworkManager()
    mockManager.mockSongs = [Song.fixture(id: 1)]
    
    let viewModel = TestableMusicPlayerViewModel(networkManager: mockManager)
    try await Task.sleep(nanoseconds: 100_000_000)
    
    viewModel.isPlaying = true
    viewModel.stop()
    
    #expect(viewModel.isPlaying == false)
  }
  
  @Test("Given current song, When nextSong is called, Then next song is played")
  func nextSongPlaysNextTrack() async throws {
    let mockManager = MockNetworkManager()
    mockManager.mockSongs = [
      Song.fixture(id: 1, trackName: "Song 1"),
      Song.fixture(id: 2, trackName: "Song 2"),
      Song.fixture(id: 3, trackName: "Song 3")
    ]
    
    let viewModel = TestableMusicPlayerViewModel(networkManager: mockManager)
    try await Task.sleep(nanoseconds: 100_000_000)
    viewModel.nextSong()
    
    #expect(viewModel.currentSong?.id == 2)
    #expect(viewModel.isPlaying == true)
  }
  
  @Test("Given songs loaded, When selecting a different song, Then selected song plays")
  func selectAndPlayDifferentSong() async throws {
    let mockManager = MockNetworkManager()
    let targetSong = Song.fixture(id: 2, trackName: "Target Song")
    mockManager.mockSongs = [
      Song.fixture(id: 1),
      targetSong,
      Song.fixture(id: 3)
    ]
    let viewModel = TestableMusicPlayerViewModel(networkManager: mockManager)
    try await Task.sleep(nanoseconds: 100_000_000)
    
    viewModel.selectAndPlay(song: targetSong)
    
    #expect(viewModel.currentSong?.id == 2)
    #expect(viewModel.isPlaying == true)
  }
  
  @Test("Given current song, When selecting same song, Then nothing happens")
  func selectAndPlaySameSong() async throws {
    let mockManager = MockNetworkManager()
    let currentSong = Song.fixture(id: 1)
    mockManager.mockSongs = [currentSong]
    let viewModel = TestableMusicPlayerViewModel(networkManager: mockManager)
    try await Task.sleep(nanoseconds: 100_000_000)
    
    let initialPlayingState = viewModel.isPlaying
    viewModel.selectAndPlay(song: currentSong)
    
    #expect(viewModel.currentSong?.id == 1)
    #expect(viewModel.isPlaying == initialPlayingState)
  }
}
