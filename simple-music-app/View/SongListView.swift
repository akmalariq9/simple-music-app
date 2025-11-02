//
//  SongListView.swift
//  simple-music-app
//
//  Created by Akmal Ariq on 02/11/25.
//

import SwiftUI

struct SongListView: View {
  let songs: [Song]
  let currentSong: Song?
  let isPlaying: Bool
  let onSongTap: (Song) -> Void
  
  var body: some View {
    List(songs) { song in
      SongRow(
        song: song,
        isCurrentSong: currentSong?.id == song.id,
        isPlaying: isPlaying
      )
      .contentShape(Rectangle())
      .onTapGesture {
        onSongTap(song)
      }
    }
    .listStyle(PlainListStyle())
  }
}

#Preview {
  SongListView(
    songs: [
      Song(id: 2, trackName: "Song 1", collectionName: "Membasuh:",  artistName: "Artist 1", artworkUrl100: "www.google.com", previewUrl: "Hola"),
    ],
    currentSong: nil,
    isPlaying: false,
    onSongTap: { _ in }
  )
}
