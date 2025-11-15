//
//  PostListViewModel.swift
//  PostBrowser-Project
//
//  Created by Richard Rodriguez on 11/13/25.
//

import Foundation
import Combine

@MainActor
final class PostListViewModel: ObservableObject {
    // Adding idle give me a way to not constantly load whenever the view is dispalyed.
    enum LoadingState {
        case idle
        case loading
        case loaded
        case error(String)
    }
    
    @Published var searchText: String = ""
    @Published private(set) var posts: [Post] = []
    @Published private(set) var loadingState: LoadingState = .idle
    @Published private(set) var favoritePosts = Set<Int>()

    private let service: PostFetching
    private var isRefreshing: Bool = false
    
    var filteredPosts: [Post] {
        // posts is all the posts from the request in services.
        guard !searchText.isEmpty else { return posts }
        
        let query = searchText.lowercased()
        return posts.filter {
            $0.title.lowercased().contains(query) ||
            $0.body.lowercased().contains(query)
        }
    }

    init(service: PostFetching) {
        self.service = service
    }
    
    convenience init() {
        self.init(service: PostService())
    }
    
    func loadIfNeeded() async {
        guard case .idle = loadingState else {
            return
        }
        await load()
    }
    
    func load() async {
        loadingState = .loading
        
        do {
            posts = try await service.fetchPosts()
            loadingState = .loaded
        }
        // Using PostError as setup in PostService
        // to give better description of error
        catch let error as PostError {
            switch error {
            case .invalidURL:
                loadingState = .error("Internal error: Bad URL")
            case .network:
                loadingState = .error("Network error, please try again")
            case .badStatusCode(let code):
                loadingState = .error("server error: \(code)")
            case .decoding:
                loadingState = .error("Something went wrong with parsing data")
                
            }
        } catch {
            loadingState = .error("Unexpected error: \(error.localizedDescription)")
        }
    }
    
    func refresh() async {
        // Prevent overlapping refreshes
        guard !isRefreshing else { return }
        isRefreshing = true
        
        // defer schedules code to run at the end of the function, no matter how the function exits —
        // whether it returns early, finishes normally, or even throws an error.
        defer { isRefreshing = false }
        
        await load()
    }
    
    func addToFavorites(id: Int) {
        favoritePosts.insert(id)
    }
}
