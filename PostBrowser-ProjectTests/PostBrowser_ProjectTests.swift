//
//  PostBrowser_ProjectTests.swift
//  PostBrowser-ProjectTests
//
//  Created by Richard Rodriguez on 11/16/25.
//

import XCTest
@testable import PostBrowser_Project

final class PostListViewModelTests: XCTestCase {
    
    // MARK: Success case
    
    @MainActor
    func test_load_success_updatesPostsAndState() async {
        // Set up posts
        let mockPost = [
            Post(userId: 1, id: 1, title: "First", body: "Body 1"),
            Post(userId: 2, id: 2, title: "Second", body: "Body 2")
            ]
        
        let mockService = MockPostService()
        mockService.postsToReturn = mockPost
        
        let sut = PostListViewModel(service: mockService)
        
        // Act
        await sut.load()
        
        // Asserts
        XCTAssertTrue(mockService.fetchCalled, "Expected fetchPosts to be called")
        XCTAssertEqual(sut.posts.count, 2, "Expected posts to only contain 2 elements")
        XCTAssertEqual(sut.posts.first?.title, "First", "Expected first element to contain title: First")
        XCTAssertEqual(sut.loadingState, .loaded, "Expected loading state to be .loaded")
    }
    
    // MARK: Failure case
    @MainActor
    func test_load_failure_setErrorState() async {
        enum DummyError: Error {
            case test
        }
        
        // Arrange
        let mockService = MockPostService()
        mockService.errorToThrow = DummyError.test
        
        let sut = PostListViewModel(service: mockService)
        
        // Act
        await sut.load()
        
        XCTAssert(mockService.fetchCalled, "Expected fetchPosts to be called")
        
        if case .error(let message) = sut.loadingState {
            XCTAssertFalse(message.isEmpty, "Expected an error message")
        } else {
            XCTFail("Expected loadingState to be .error got \(sut.loadingState)")
        }
        
    }
}


extension PostListViewModel.LoadingState: @retroactive Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        switch (lhs, rhs) {
        case (.loading, .loading), (.loaded, .loaded):
            return true
        case (.error, .error):
            return true
        default:
            return false
        }
    }
}
