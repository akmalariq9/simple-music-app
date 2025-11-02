//
//  MusicPlayerViewModel.swift
//  simple-music-app
//
//  Created by Akmal Ariq on 02/11/25.
//

import Foundation
import Combine
import AVFoundation

@MainActor
class MusicPlayerViewModel: ObservableObject {
  @Published var songs: [Song] = []
  @Published var searchText = ""
  @Published var filteredSongs: [Song] = []
  @Published var currentSong: Song?
  @Published var isPlaying: Bool = false
  @Published var isLoading: Bool = false
  @Published var errorMessage: String?
  private var currentTime: CMTime = .zero
  private var player: AVPlayer?
  private var currentSongIndex = 0
  
  private let networkManager = NetworkManager()
  
  init() {
    fetchSongs()
  }
  
  func fetchSongs() {
    isLoading = true
    errorMessage = nil
    
    networkManager.fetchSongs { [weak self] result in
      DispatchQueue.main.async {
        self?.isLoading = false
        
        switch result {
        case .success(let songs):
          self?.songs = songs
          self?.filteredSongs = songs
          self?.currentSong = songs.first
        case .failure(let error):
          self?.handleError(error)
        }
      }
    }
  }
  
  func playPause() {
    guard let currentSong = currentSong else { return }
    
    if isPlaying {
      currentTime = player?.currentTime() ?? .zero
      player?.pause()
    } else {
      if player == nil {
        playSong(song: currentSong)
      } else {
        player?.seek(to: currentTime)
        player?.play()
      }
    }
    isPlaying.toggle()
  }
  
  func searchSongs() {
    if searchText.isEmpty {
      filteredSongs = songs
    } else {
      filteredSongs = songs.filter { song in
        song.trackName.localizedCaseInsensitiveContains(searchText) ||
        song.artistName.localizedCaseInsensitiveContains(searchText)
      }
    }
  }
  
  func stop() {
    player?.pause()
    player = nil
    isPlaying = false
  }
  
  func nextSong() {
    currentSongIndex = (currentSongIndex + 1) % songs.count
    currentSong = songs[currentSongIndex]
    playSong(song: currentSong!)
    isPlaying = true
  }
  
  func previousSong() {
    currentSongIndex = (currentSongIndex - 1 + songs.count) % songs.count
    currentSong = songs[currentSongIndex]
    playSong(song: currentSong!)
    isPlaying = true
  }
  
  func selectAndPlay(song: Song) {
    if currentSong?.id == song.id {
      return
    }
    stop()
    self.currentSong = song
    if let index = songs.firstIndex(where: { $0.id == song.id }) {
      currentSongIndex = index
    }
    playSong(song: song)
    isPlaying = true
  }
  
  private func playSong(song: Song) {
    print("Preview URL: \(song.previewUrl)")
    guard let url = URL(string: song.previewUrl) else { return }
    
    let playerItem = AVPlayerItem(url: url)
    player = AVPlayer(playerItem: playerItem)
    
    player?.play()
  }
  
  private func handleError(_ error: NetworkError) {
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
