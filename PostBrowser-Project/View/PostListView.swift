//
//  PostListView.swift
//  PostBrowser-Project
//
//  Created by Richard Rodriguez on 11/13/25.
//

import SwiftUI

struct PostListView: View {
    @StateObject private var viewModel = PostListViewModel()

    var body: some View {
        NavigationStack {
            ZStack {
                switch viewModel.loadingState {
                case .loading:
                    Color.black.opacity(0.3)
                        .ignoresSafeArea()
                    
                    ProgressView("Loading...")
                        .padding(16)
                        .background(.ultraThinMaterial)
                        .cornerRadius(16)
                case .loaded:
                    VStack {
                        TextField("Search posts", text: $viewModel.searchText)
                            .padding()
                            .background(Color(.secondarySystemBackground))
                            .cornerRadius(8)
                            .padding()
                        
                        List(viewModel.filteredPosts) { post in
                            NavigationLink {
                                PostDetailView(post: post)
                            } label: {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(post.title)
                                        .font(.headline)
                                    Text(post.body)
                                        .font(.subheadline)
                                        .lineLimit(2)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                    }
                case .error(let errorMessage):
                    Text("Error: \(errorMessage)")
                        .foregroundColor(.red)
                }
            }
            .navigationTitle("Posts")
        }
    }
}
