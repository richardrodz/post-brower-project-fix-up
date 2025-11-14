//
//  PostService.swift
//  PostBrowser-Project
//
//  Created by Richard Rodriguez on 11/13/25.
//

import Foundation

// NOTE: This is not protocol-driven, not very testable, etc.
// It also force-unwraps like crazy 🙃

final class PostService {
    func fetchPosts(completion: @escaping ([Post]?, Error?) -> Void) {
        let url = URL(string: "https://jsonplaceholder.typicode.com/posts")! // force unwrap

        URLSession.shared.dataTask(with: url) { data, response, error in
            if error != nil {
                completion(nil, error)
                return
            }

            // no statusCode check, no guard
            let posts = try! JSONDecoder().decode([Post].self, from: data!) // force unwrap + try!
            completion(posts, nil)  // not guaranteed to be on main
        }.resume()
    }
}
