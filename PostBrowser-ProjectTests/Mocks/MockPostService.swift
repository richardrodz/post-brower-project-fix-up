//
//  MockPostService.swift
//  PostBrowser-Project
//
//  Created by Richard Rodriguez on 11/16/25.
//

@testable import PostBrowser_Project
import Foundation

final class MockPostService: PostFetching {
    
    // What the mock will return
    var postsToReturn: [Post] = []
    var errorToThrow: Error?
    
    // For assertions ('was this actually called?)
    private(set) var fetchCalled = false
    
    func fetchPosts() async throws -> [Post] {
        fetchCalled = true
        
        if let errorToThrow {
            throw errorToThrow
        }
        
        return postsToReturn
    }
}
