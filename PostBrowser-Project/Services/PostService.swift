//
//  PostService.swift
//  PostBrowser-Project
//
//  Created by Richard Rodriguez on 11/13/25.
//

import Foundation

// Polish Create domain-specific error type
enum PostError: Error {
    case invalidURL
    case network(Error)
    case badStatusCode(Int)
    case decoding(Error)
}

protocol PostFetching {
    func fetchPosts() async throws -> [Post]
}

final class PostService: PostFetching {
    func fetchPosts() async throws -> [Post] {
        guard let url = URL(string: "https://jsonplaceholder.typicode.com/posts") else {
            throw PostError.invalidURL
        }
        
        do {
            // the outer do is for this failing and then catching.
            let (data, response) = try await URLSession.shared.data(from: url)
            
            // Probably too much to think about during an interview.
            // The the other errors are useful though.
            guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
                throw PostError.badStatusCode((response as? HTTPURLResponse)?.statusCode ?? -1)
            }
            
            // This is good on it's own, but if I want to hanlde domain-error might be useful to go at the source
            //return try JSONDecoder().decode([Post].self, from: data)
            
            do {
                return try JSONDecoder().decode([Post].self, from: data)
            } catch {
                throw PostError.decoding(error)
            }
        } catch {
            throw PostError.network(error)
        }
    }
}
