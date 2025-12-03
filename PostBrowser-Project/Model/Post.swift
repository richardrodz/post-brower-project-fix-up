//
//  Post.swift
//  PostBrowser-Project
//
//  Created by Richard Rodriguez on 11/13/25.
//

import Foundation

struct Post: Identifiable, Codable, Hashable {
    let userId: Int
    let id: Int
    let title: String
    let body: String
}
