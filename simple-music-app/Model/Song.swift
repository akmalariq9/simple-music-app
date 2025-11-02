//
//  Song.swift
//  simple-music-app
//
//  Created by Akmal Ariq on 02/11/25.
//

import Foundation

struct Song: Identifiable, Codable {
    let id: Int
    let trackName: String
    let collectionName: String
    let artistName: String
    let artworkUrl100: String
    let previewUrl: String

    enum CodingKeys: String, CodingKey {
        case id = "trackId"
        case trackName
        case collectionName
        case artistName
        case artworkUrl100
        case previewUrl
    }
}

struct SearchResponse: Codable {
    let results: [Song]
}
