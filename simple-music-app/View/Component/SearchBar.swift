//
//  SearchBar.swift
//  simple-music-app
//
//  Created by Akmal Ariq on 02/11/25.
//

import SwiftUI

struct SearchBar: View {
  @Binding var text: String
  let onSearchChanged: () -> Void
  
  var body: some View {
    HStack {
      Image(systemName: "magnifyingglass")
        .foregroundColor(.gray)
      
      TextField("Search songs...", text: $text)
        .onChange(of: text) { _, _ in
          onSearchChanged()
        }
      
      if !text.isEmpty {
        Button(action: {
          text = ""
          onSearchChanged()
        }) {
          Image(systemName: "xmark.circle.fill")
            .foregroundColor(.gray)
        }
      }
    }
    .padding(8)
    .background(Color(.systemGray6))
    .cornerRadius(10)
  }
}

#Preview {
  SearchBar(text: .constant(""), onSearchChanged: {
  })
}
