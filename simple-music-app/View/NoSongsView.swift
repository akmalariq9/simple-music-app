//
//  NoSongsView.swift
//  simple-music-app
//
//  Created by Akmal Ariq on 02/11/25.
//

import SwiftUI

struct NoSongsView: View {
  var body: some View {
    Spacer()
    Text("No songs available")
      .foregroundColor(.gray)
      .font(.title)
      .padding(.top, 16)
    Spacer()
  }
}

#Preview {
  NoSongsView()
}
