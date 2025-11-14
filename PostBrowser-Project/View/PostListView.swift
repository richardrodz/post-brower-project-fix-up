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
            VStack {
                TextField("Search posts", text: $viewModel.searchText)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(8)
                    .padding()

                if let error = viewModel.errorMessage {
                    Text("Error: \(error)")
                        .foregroundColor(.red)
                }

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
            .navigationTitle("Posts")
            .onAppear {
                viewModel.load() // Called every time it appears
            }
        }
    }
}

struct PostDetailView: View {
    let post: Post

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                Text(post.title)
                    .font(.title2)
                    .bold()
                Text(post.body)
                    .font(.body)
            }
            .padding()
        }
        .navigationTitle("Detail")
    }
}
