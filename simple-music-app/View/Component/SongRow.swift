//
//  SongRow.swift
//  simple-music-app
//
//  Created by Akmal Ariq on 02/11/25.
//

import SwiftUI

struct SongRow: View {
  let song: Song
  let isCurrentSong: Bool
  let isPlaying: Bool
  
  var body: some View {
    HStack(spacing: 12) {
      AsyncImage(url: URL(string: song.artworkUrl100)) { phase in
        switch phase {
        case .empty:
          ProgressView()
            .frame(width: 60, height: 60)
        case .success(let image):
          image
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(width: 60, height: 60)
            .cornerRadius(8)
        case .failure:
          Image(systemName: "music.note")
            .frame(width: 60, height: 60)
            .background(Color.gray.opacity(0.3))
            .cornerRadius(8)
        @unknown default:
          EmptyView()
        }
      }
      
      VStack(alignment: .leading, spacing: 4) {
        Text(song.trackName)
          .font(.headline)
          .lineLimit(1)
        
        Text(song.artistName)
          .font(.subheadline)
          .foregroundColor(.gray)
          .lineLimit(1)
      }
      
      Spacer()
      
      if isCurrentSong {
        Image(systemName: isPlaying ? "speaker.wave.3.fill" : "speaker.fill")
          .foregroundColor(.blue)
          .font(.title3)
      }
    }
    .padding(.vertical, 4)
  }
}

#Preview {
  SongRow(
    song: Song(id: 1, trackName: "Song Title", collectionName: "Album Name", artistName: "Artist Name", artworkUrl100: "https://example.com/thumbnail.jpg", previewUrl: "Google.com"),
    isCurrentSong: true,
    isPlaying: true
  )
}
