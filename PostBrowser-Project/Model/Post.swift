//
//  Post.swift
//  PostBrowser-Project
//
//  Created by Richard Rodriguez on 11/13/25.
//

import Foundation

// 👇 Simple model (this matches jsonplaceholder's /posts endpoint)
struct Post: Identifiable, Codable {
    let userId: Int
    let id: Int
    let title: String
    let body: String
}
