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
    
    enum SortType {
        case titleAsc
        case titleDesc
        case idAsc
        case idDesc
    }
    
    @Published var searchText: String = ""
    @Published private(set) var posts: [Post] = []
    @Published private(set) var loadingState: LoadingState = .idle
    @Published private(set) var favoritePosts = Set<Int>()
    @Published var sortType: SortType = .titleAsc
    @Published var showFavoritesOnly: Bool = false

    private let service: PostFetching
    private var isRefreshing: Bool = false
    
    var filteredPosts: [Post] {
        var result = posts
        
        // 1. Favorite filter
        if showFavoritesOnly {
            result = result.filter { favoritePosts.contains($0.id) }
        }
        
        // 2. Search filter
        if !searchText.isEmpty {
            let query = searchText.lowercased()
            result = result.filter {
                $0.title.lowercased().contains(query) ||
                $0.body.lowercased().contains(query)
            }
        }
        
        // 3. Sorting
         switch sortType {
         case .titleAsc:
             result.sort {
                 $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending
                 //$0.title.lowercased() > $1.title.lowercased()
             }
         case .titleDesc:
             result.sort {
                 $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedDescending
                 //$0.title.lowercased() > $1.title.lowercased()
             }
         case .idAsc:
             result.sort { $0.id < $1.id }
         case .idDesc:
             result.sort { $0.id > $1.id }
         }

         return result
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
    
    func toggleFavorites(id: Int) {
        if favoritePosts.contains(id) {
            favoritePosts.remove(id)
        } else {
            favoritePosts.insert(id)
        }
    }
}
