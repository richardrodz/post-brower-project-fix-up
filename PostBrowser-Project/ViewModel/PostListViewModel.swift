//
//  PostListViewModel.swift
//  PostBrowser-Project
//
//  Created by Richard Rodriguez on 11/13/25.
//

import Foundation
import Combine

// ViewModel does networking directly via concrete service.
// No clear error state, no loading state, not thread-safe from UI perspective.

final class PostListViewModel: ObservableObject {

    @Published var posts: [Post] = []
    @Published var searchText: String = ""
    @Published var filteredPosts: [Post] = [] // duplicated derived state
    @Published var errorMessage: String? = nil

    private let service = PostService() // hard-coded dependency

    private var cancellables = Set<AnyCancellable>()

    init() {
        // Filter logic is a bit clumsy and not debounced.
        $searchText
            .sink { [weak self] query in
                guard let self else { return }

                if query.isEmpty {
                    self.filteredPosts = self.posts
                } else {
                    self.filteredPosts = self.posts.filter {
                        $0.title.lowercased().contains(query.lowercased()) ||
                        $0.body.lowercased().contains(query.lowercased())
                    }
                }
            }
            .store(in: &cancellables)
    }

    func load() {
        // No loading state here.
        service.fetchPosts { [weak self] posts, error in
            guard let self else { return }

            if let error = error {
                self.errorMessage = error.localizedDescription
                return
            }

            if let posts = posts {
                // ❗️This might be called on a background thread
                self.posts = posts
                self.filteredPosts = posts
            }
        }
    }
}
