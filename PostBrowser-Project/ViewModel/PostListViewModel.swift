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
    enum LoadingState {
        case loading
        case loaded
        case error(String)
    }
    
    @Published var searchText: String = ""
    @Published private(set) var posts: [Post] = []
    @Published private(set) var loadingState: LoadingState = .loading

    private let service: PostFetching
    private var isRefreshing: Bool = false
    
    var filteredPosts: [Post] {
        guard !searchText.isEmpty else { return posts }
        
        let query = searchText.lowercased()
        return posts.filter {
            $0.title.lowercased().contains(query) ||
            $0.body.lowercased().contains(query)
        }
    }

    init(service: PostFetching) {
        self.service = service
        
        // Load services when ViewModel is initialize
        Task { await self.load() }
    }
    
    convenience init() {
        self.init(service: PostService())
    }

    func load() async {
        loadingState = .loading
        
        do {
            posts = try await service.fetchPosts()
            loadingState = .loaded
        } catch {
            loadingState = .error(error.localizedDescription)
        }
    }
}
