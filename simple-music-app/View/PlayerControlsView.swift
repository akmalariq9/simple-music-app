//
//  PlayerControlsView.swift
//  simple-music-app
//
//  Created by Akmal Ariq on 02/11/25.
//

import SwiftUI

struct PlayerControlsView: View {
  let currentSong: Song
  let isPlaying: Bool
  let onPrevious: () -> Void
  let onPlayPause: () -> Void
  let onNext: () -> Void
  
  var body: some View {
    VStack {
      HStack {
        VStack(alignment: .leading) {
          Text(currentSong.trackName)
            .font(.headline)
            .bold()
            .lineLimit(1)
          Text(currentSong.artistName)
            .font(.subheadline)
        }
        Spacer()
        
        HStack {
          Button(action: onPrevious) {
            Image(systemName: "backward.fill")
              .font(.headline)
          }
          
          Button(action: onPlayPause) {
            Image(systemName: isPlaying ? "pause.fill" : "play.fill")
              .font(.headline)
          }
          
          Button(action: onNext) {
            Image(systemName: "forward.fill")
              .font(.headline)
          }
        }
      }
      .padding()
    }
  }
}

#Preview {
  PlayerControlsView(
    currentSong: Song(id: 1, trackName: "Song Title", collectionName: "Album Name", artistName: "Artist Name", artworkUrl100: "https://example.com/thumbnail.jpg", previewUrl: "google.com"),
    isPlaying: true,
    onPrevious: {},
    onPlayPause: {},
    onNext: {}
  )
}
