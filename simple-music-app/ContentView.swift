//
//  ContentView.swift
//  simple-music-app
//
//  Created by Akmal Ariq on 02/11/25.
//

import SwiftUI

struct ContentView: View {
  @StateObject private var viewModel = MusicPlayerViewModel()
  
  var body: some View {
    VStack {
      if let errorMessage = viewModel.errorMessage {
        Text(errorMessage)
          .foregroundColor(.red)
          .padding()
      }
      
      SearchBar(text: $viewModel.searchText, onSearchChanged: {
        viewModel.searchSongs()
      })
      .padding([.top, .leading, .trailing])
      
      if viewModel.isLoading {
        Spacer()
        ProgressView("Loading songs...")
          .progressViewStyle(CircularProgressViewStyle())
        Spacer()
      } else if viewModel.filteredSongs.isEmpty {
        NoSongsView()
      } else {
        SongListView(
          songs: viewModel.filteredSongs,
          currentSong: viewModel.currentSong,
          isPlaying: viewModel.isPlaying,
          onSongTap: { song in
            viewModel.selectAndPlay(song: song)
          }
        )
      }
      if let currentSong = viewModel.currentSong {
        PlayerControlsView(
          currentSong: currentSong,
          isPlaying: viewModel.isPlaying,
          onPrevious: { viewModel.previousSong() },
          onPlayPause: { viewModel.playPause() },
          onNext: { viewModel.nextSong() }
        )
      }
    }
    .onAppear {
      viewModel.fetchSongs()
    }
  }
}

#Preview {
  ContentView()
}
