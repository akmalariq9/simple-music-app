//
//  NetworkManager.swift
//  simple-music-app
//
//  Created by Akmal Ariq on 02/11/25.
//

import Foundation

class NetworkManager {
  private let apiURL = "https://itunes.apple.com/search?term=Hindia&entity=song&limit=20"
  
  func fetchSongs(completion: @escaping (Result<[Song], NetworkError>) -> Void) {
    guard let url = URL(string: apiURL) else {
      completion(.failure(.invalidURL))
      return
    }
    
    URLSession.shared.dataTask(with: url) { data, response, error in
      if let error = error {
        completion(.failure(.networkError(error)))
        return
      }
      
      guard let httpResponse = response as? HTTPURLResponse else {
        completion(.failure(.invalidResponse))
        return
      }
      
      if !(200...299).contains(httpResponse.statusCode) {
        let statusCode = httpResponse.statusCode
        completion(.failure(.serverError(statusCode)))
        return
      }
      
      guard let data = data else {
        completion(.failure(.noData))
        return
      }
      
      do {
        let searchResponse = try JSONDecoder().decode(SearchResponse.self, from: data)
        completion(.success(searchResponse.results))
      } catch {
        completion(.failure(.decodingError(error)))
      }
    }
    .resume()
  }
}

enum NetworkError: Error {
  case invalidURL
  case networkError(Error)
  case serverError(Int)
  case noData
  case invalidResponse
  case decodingError(Error)
}
